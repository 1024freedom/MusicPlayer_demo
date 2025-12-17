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

    // 内部状态: "normal" (未下载),  "downloading"(下载中),"downloaded" (已下载)
    state: "normal"

    // 组件加载或数据变更时检查是否已存在
    onSongDataChanged: {
        checkLocalStatus()
    }

    Component.onCompleted: {
        checkLocalStatus()
    }

    function checkLocalStatus() {
        if (!songData || !songData.id) return;
        // 调用 C++ 函数检查本地是否已存在
        if (backend.localExist(songData.id)) {
            root.state = "downloaded"
        } else {
            if(root.state!=="downloading"){
                root.state = "normal"
            }
        }
    }

    // 按钮鼠标交互和背景区域
    MouseArea {
        id: bg
        anchors.fill: parent
        hoverEnabled: true
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
        if (!songData || !songData.url || !songData.id) {
            console.error("歌曲数据不完整，无法下载")
            return
        }

        root.state = "downloading" // 立即切换UI状态

        // 1. 构造文件名 (例如: 歌手 - 歌名.mp3)
        var fileName = songData.artists + " - " + songData.name + ".mp3"
        var taskId = songData.id.toString()

        // 2. 调用 C++: 添加任务 (创建线程)
        backend.addTask(songData.url, fileName, taskId)//任务id就是歌曲id

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
