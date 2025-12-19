import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 30
    height: 30

    // 接收从外部传来的歌曲信息对象
    // 包含: id, name, artists, album, coverImg, url, allTime
    property var songData: ({})
    property var thisTheme:p_theme.m_currentTheme

    // 引用 C++ 后端单例
    property var backend: p_musicDownloader

    //错误信号
    signal error(string msg)
    // 内部状态: "normal" (未下载),  "downloading"(下载中),"downloaded" (已下载)

    state: "normal"

    // 组件加载或数据变更时检查状态
    onSongDataChanged: {
        checkLocalStatus()
    }

    Component.onCompleted: {
        checkLocalStatus()
    }

    Timer{//确保页面显示与后端状态同步
        id:statusRefesher
        interval: 1000
        repeat: true
        running: root.visible&&songData&&songData.id
        triggeredOnStart: true//启动时立即触发一次
        onTriggered: {
            checkLocalStatus()
        }
    }

    function checkLocalStatus() {
        if (!songData || !songData.id){
            root.state="normal"
            return
        }
        //已下载
        if (backend.localExist(songData.id)) {
            root.state = "downloaded"
            return
        }
        //正下载
        if(backend.isDownloading(songData.id)){
            root.state="downloading"
            return
        }
        root.state="normal"
        return
    }

    // 按钮鼠标交互和背景区域
    MouseArea {
        id: bg
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        property bool isHovered: false
        property string source: if(root.state==="normal")return "qrc:/download"
            else if(root.state==="downloaded")return "qrc:/downloaded"
        else if(root.state==="downloading")return "qrc:/downloading"
        onClicked: {
            if (root.state === "normal") {
                startDownloadProcess()
            }
        }
        onEntered: {
            isHovered=true
        }
        onExited: {
            isHovered=false
        }

        Rectangle{
            anchors.fill: parent
            radius: parent.width/2
            color: if(parent.isHovered)return thisTheme.itemHoverColor
            else return thisTheme.alternateRowColor
        }

        // 显示的图标/文本
        ThemeImage{
            id:icon
            width: parent.width*0.5
            height: width
            anchors.centerIn: parent
            source: parent.source
            color: thisTheme.accentColor
            transformOrigin: Item.Center//确保变为进度条旋转时旋转中心在图片中心
        }
        //旋转动画组件
        RotationAnimator{
            target: icon
            from:0
            to:360
            duration: 1000//旋转一圈需要1000ms
            loops:Animation.Infinite//无限循环
            running: root.state==="downloading"
            //下载完成动画停止时，将角度重置为0
            onRunningChanged: {
                if(!running){
                    icon.rotation=0
                }
            }
        }
    }



    // 逻辑处理函数
    function startDownloadProcess() {
        if (!songData /*|| !songData.url */|| !songData.id) {
            console.error("歌曲数据不完整，无法下载")
            error("歌曲数据不完整，无法下载")
            return
        }

        //如果url为空，先获取url
        if(!songData.url||songData.url===""){
            console.log("检测到 URL 为空，正在请求 API 获取...")
            root.state = "downloading" // 立即切换UI状态
            var id=songData.id
            p_musicRes.getMusicUrl({id,callBack:function(res){
                if(res&&res.url){
                    console.log("成功获取 URL:", res.url)

                    // 更新当前组件的 songData 数据
                    songData.url = res.url

                    // 递归调用自己，这次 url 不为空了，就会走下载逻辑
                    startDownloadProcess()
                }else{
                    console.error("获取 URL 失败或该歌曲需要 VIP")
                    error("获取 URL 失败或该歌曲需要 VIP")
                    root.state = "normal"
                }
            }})
            return
        }

        root.state = "downloading" // 立即切换UI状态

        // 1. 构造文件名 (例如: 歌手 - 歌名.mp3)
        var fileName = songData.artists + " - " + songData.name + ".mp3"
        var taskId = songData.id.toString()

        // 2. 调用 C++: 添加任务 (创建线程)
        backend.addTask(songData.url, fileName, taskId)//--------任务id就是歌曲id--------

        // 3. 调用 C++: 开始下载
        // 传递 taskId 和 完整的 songData (QVariantMap) 用于存库
        backend.startDownload(taskId, songData)
    }

    // 监听后端数据变化，如果下载完成，数据库更新，这里也会收到信号
    Connections {
        target: backend
        function onDataChanged() {
            // 当数据库更新时（下载完成写入后），再次检查状态
            checkLocalStatus()
        }
    }
}
