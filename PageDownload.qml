import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property var thisTheme: p_theme.m_currentTheme
    color: thisTheme.contentBackgroundColor
    anchors.fill: parent

    // ---------------------------------------------------------
    // 状态管理
    // ---------------------------------------------------------
    property int currentTab: 0 // 0: 已下载, 1: 正在下载
    property bool isNewest: true//数据是否最新，用于删除下载记录后更新页面
    //刷新用定时器
    Timer{
        id:refreshTimer
        interval: 50
        repeat: false
        onTriggered: {
            var currentData=p_musicDownloader.data
            downloadedListView.model=[]//置空欺骗 ListView，让它认为源数据变了，从而强制重新渲染
            downloadedListView.model=currentData
            root.isNewest=true
        }
    }

    onIsNewestChanged:{
        if(isNewest===false){
            refreshTimer.restart()
        }
    }

    // ---------------------------------------------------------
    // 顶部标题栏与 Tab
    // ---------------------------------------------------------
    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: thisTheme.windowBackgroundColor
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 30
            spacing: 30

            // 标题
            Text {
                text: "下载管理"
                font.pixelSize: 24
                font.bold: true
                color: thisTheme.primaryTextColor
            }

            // Tab 切换按钮组
            Row {
                spacing: 20
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 10

                TabButtonText {
                    text: "已下载歌曲"
                    isSelected: root.currentTab === 0
                    onClicked: root.currentTab = 0
                }

                TabButtonText {
                    text: "正在下载"
                    isSelected: root.currentTab === 1
                    onClicked: root.currentTab = 1
                }
            }
        }

        //底部分割线
        Rectangle {
            width: parent.width
            height: 1
            color: thisTheme.dividerColor
            anchors.bottom: parent.bottom
        }
    }

    // ---------------------------------------------------------
    // 内容区域
    // ---------------------------------------------------------
    StackLayout {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        currentIndex: root.currentTab

        // ================= Tab 1: 已下载列表 (Table Style) =================
        Item {
            // 表头
            RowLayout {
                id: tableHeader
                height: 40
                width: parent.width
                anchors.top: parent.top
                spacing: 0
                z: 5

                HeaderItem { text: "音乐标题"; widthWeight: 2.5 }
                HeaderItem { text: "歌手"; widthWeight: 1.5 }
                HeaderItem { text: "专辑"; widthWeight: 1 }
                HeaderItem { text: "时长"; widthWeight: 1 }
            }

            ListView {
                id: downloadedListView
                anchors.top: tableHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                // 绑定 C++ loadAllDownloads 返回的数据
                model: p_musicDownloader.data

                // 滚动条
                ScrollBar.vertical: ScrollBar {
                    id: vbar
                    policy: ScrollBar.AsNeeded
                    width: 10

                    // 自定义滑块
                    contentItem: Rectangle {
                        implicitWidth: parent.width
                        implicitHeight: 100
                        radius: width / 2

                        // 颜色逻辑：
                        // 按下时 -> 使用主题的强调色
                        // 平时   -> 使用主题文字颜色的半透明版 (保证在任何背景下都能看见)
                        color: vbar.pressed ? p_theme.m_currentTheme.itemSelectedColor
                                            : Qt.rgba(p_theme.m_currentTheme.primaryTextColor.r,
                                                      p_theme.m_currentTheme.primaryTextColor.g,
                                                      p_theme.m_currentTheme.primaryTextColor.b,
                                                      0.5) // 0.5 透明度，既明显又不遮挡太多

                        //简单的悬停变暗效果
                        opacity: vbar.active || vbar.pressed ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }

                delegate: Rectangle {
                    width: downloadedListView.width
                    height: 50


                    // 鼠标悬停高亮
                    property bool hovered: false
                    color: hovered ? thisTheme.itemHoverColor : (index % 2 === 0 ? thisTheme.alternateRowColor :thisTheme.contentBackgroundColor)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                        onDoubleClicked: {
                            console.log("播放本地文件:", modelData.savePath)
                            var findIndex=p_musicRes.indexOf(modelData.id)
                            if(findIndex===-1){
                                p_musicRes.thisPlayListInfo.insert(p_musicRes.thisPlayCurrent+1,modelData)
                                p_musicRes.thisPlayListInfoChanged()
                                p_musicRes.thisPlayCurrent+=1
                            }else{
                                p_musicRes.thisPlayCurrent=findIndex
                            }

                            p_musicPlayer.playMusic(modelData.id,modelData)
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 10

                        // 1. 歌名
                        Item {
                            Layout.preferredWidth: parent.width * 0.3 // 对应表头权重 3
                            Layout.fillHeight: true
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.name
                                color: thisTheme.primaryTextColor
                                font.pixelSize: 14
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // 2. 歌手
                        Item {
                            Layout.preferredWidth: parent.width * 0.3
                            Layout.fillHeight: true
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.artists
                                color: thisTheme.secondaryTextColor
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // 3. 专辑
                        Item {
                            Layout.preferredWidth: parent.width * 0.2
                            Layout.fillHeight: true
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.album
                                color: thisTheme.secondaryTextColor
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // 4. 时长
                        Item {
                            Layout.preferredWidth: parent.width * 0.1
                            Layout.fillHeight: true
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.allTime
                                color: thisTheme.secondaryTextColor
                                font.pixelSize: 13
                            }
                        }
                        Item {
                            Layout.preferredWidth: parent.width * 0.1
                            Layout.fillHeight: true
                            ToolTipButtom{
                                width: 20
                                height: width
                                anchors.verticalCenter: parent.verticalCenter
                                source:"qrc:/delete"
                                hintText: "删除"
                                hoveredColor: thisTheme.itemHoverColor
                                color: "#00000000"
                                onClicked: {
                                    p_musicDownloader.removeDownload(modelData.id)
                                    root.isNewest=false
                                }
                            }
                        }

                    }
                }
            }

            // 空状态
            Text {
                anchors.centerIn: parent
                text: "暂无已下载歌曲"
                font.pointSize: 12
                color: thisTheme.disabledTextColor
                visible: p_musicDownloader.data.length === 0
            }
        }

        // ================= Tab 2: 正在下载列表 =================
        Item {
            id:tab2
            // 处理 Map 到 List 的转换
            property var downloadingKeys: []

            function refreshKeys() {
                downloadingKeys=p_musicDownloader.getTaskKeys()
            }

            Component.onCompleted: refreshKeys()

            Connections {
                target: p_musicDownloader
                function onDownloadInfosChanged(){
                    tab2.refreshKeys()
                }
            }

            ListView {
                id: downloadingListView
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                clip: true
                //数据源
                model: parent.downloadingKeys//taskId数组

                delegate: Rectangle {
                    id: taskDelegate
                    width: downloadingListView.width
                    height: 80
                    color: thisTheme.contentBackgroundColor
                    radius: 8
                    border.color: thisTheme.dividerColor
                    border.width: 1

                    property string taskId: modelData
                    // 获取 C++ 线程对象
                    property var taskObj: p_musicDownloader.getTaskById[taskId]

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 20

                        // 图标
                        Rectangle {
                            width: 50; height: 50
                            color: thisTheme.accentColor
                            radius: 4
                            Text {
                                anchors.centerIn: parent
                                text: "MP3"
                                color: thisTheme.disabledTextColor
                                font.bold: true
                            }
                        }

                        // 进度与信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "任务: " + taskId
                                    color: thisTheme.primaryTextColor
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }
                                Text {

                                    text: taskObj ? Math.floor(taskObj.getProgressValue * 100) + "%" : "0%"
                                    color: thisTheme.accentColor
                                    font.pixelSize: 12
                                }
                            }

                            // 进度条背景
                            Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                color: thisTheme.itemSelectedColor
                                radius: 2

                                // 进度条前景
                                Rectangle {
                                    width: parent.width * (taskObj ? taskObj.getProgressValue : 0)
                                    height: parent.height
                                    color: thisTheme.accentColor
                                    radius: 2

                                    // 简单的动画效果
                                    Behavior on width { NumberAnimation { duration: 100 } }
                                }
                            }
                        }

                        // 操作按钮区
                        Row {
                            spacing: 10


                            // 暂停/继续按钮
                            ToolTipButtom {
                                width: 25; height: width
                                anchors.verticalCenter: parent.verticalCenter
                                property bool isPaused: false
                                hoveredColor: thisTheme.itemHoverColor
                                color: "00000000"
                                source:if(!isPaused)return "qrc:/play"
                                       else return "qrc:/pause"
                                onClicked:{
                                    isPaused=!isPaused
                                    if(isPaused){
                                        p_musicDownloader.pauseDownload(taskId)
                                    }else{
                                        p_musicDownloader.startDownload(taskId)
                                    }
                                }

                                onEntered: {
                                    scale=1.1
                                }
                                onExited: {
                                    scale=1
                                }
                                Behavior on scale {
                                    ScaleAnimator{
                                        duration: 200
                                        easing.type: Easing.InOutQuart
                                    }
                                }
                                hintText: if(!isPaused)return "暂停"
                                          else return "播放"
                            }

                            // 取消按钮
                            ToolTipButtom {
                                width: 25; height: width
                                anchors.verticalCenter: parent.verticalCenter
                                source:"qrc:/delete"
                                hoveredColor: thisTheme.itemHoverColor
                                color: "00000000"
                                onClicked:{
                                    p_musicDownloader.cancelDownload(taskId)
                                }

                                onEntered: {
                                    scale=1.1
                                }
                                onExited: {
                                    scale=1
                                }
                                Behavior on scale {
                                    ScaleAnimator{
                                        duration: 200
                                        easing.type: Easing.InOutQuart
                                    }
                                }
                                hintText: "删除任务"
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "当前没有正在进行的下载任务"
                font.pointSize: 12
                color: thisTheme.disabledTextColor
                visible: parent.downloadingKeys.length === 0
            }
        }
    }

    // ---------------------------------------------------------
    // 内部辅助组件 (为了保持文件整洁，定义在内部)
    // ---------------------------------------------------------

    // 1. 简单的文字 Tab 按钮
    component TabButtonText: MouseArea {
        property string text
        property bool isSelected
        width: label.implicitWidth
        height: 30
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Text {
            id: label
            text: parent.text
            font.pixelSize: 16
            font.bold: parent.isSelected
            color: parent.isSelected ? thisTheme.primaryTextColor : (parent.containsMouse ? thisTheme.primaryTextColor : thisTheme.secondaryTextColor)

            // 选中时的下划线
            Rectangle {
                width: parent.width
                height: 3
                color: thisTheme.accentColor
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -6
                visible: parent.parent.isSelected
            }
        }
    }

    // 2. 表头单元格
    component HeaderItem: Item {
        property string text
        property double widthWeight: 1
        Layout.preferredWidth: parent.width * (widthWeight / 9.0) // 总权重约为 9
        Layout.fillHeight: true

        Text {
            text: parent.text
            color: thisTheme.disabledTextColor
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
        }

        // 分割竖线
        Rectangle {
            width: 1; height: 16
            color: thisTheme.dividerColor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: true
        }
    }
}
