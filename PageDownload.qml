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

                HeaderItem { text: "音乐标题"; widthWeight: 4 }
                HeaderItem { text: "歌手"; widthWeight: 2 }
                HeaderItem { text: "专辑"; widthWeight: 2 }
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
                model: musicDownloader.data

                // 滚动条样式
                ScrollBar.vertical: ScrollBar {
                    width: 8
                    policy: ScrollBar.AsNeeded
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
                            // 这里可以调用播放器接口，例如 player.playLocal(modelData.savePath)
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 10

                        // 1. 歌名
                        Item {
                            Layout.preferredWidth: parent.width * 0.4 // 对应表头权重 4
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
                            Layout.preferredWidth: parent.width * 0.2
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
                    }
                }
            }

            // 空状态
            Text {
                anchors.centerIn: parent
                text: "暂无已下载歌曲"
                font.pointSize: 12
                color: thisTheme.disabledTextColor
                visible: musicDownloader.data.length === 0
            }
        }

        // ================= Tab 2: 正在下载列表 =================
        Item {
            // 处理 Map 到 List 的转换
            property var downloadingKeys: []

            function refreshKeys() {
                var map = musicDownloader.downloadInfos
                if (map) {
                    downloadingKeys = Object.keys(map)
                } else {
                    downloadingKeys = []
                }
            }

            Component.onCompleted: refreshKeys()

            Connections {
                target: musicDownloader
                function onDownloadInfosChanged() { refreshKeys() }
            }

            ListView {
                id: downloadingListView
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                clip: true

                model: parent.downloadingKeys

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
                    property var taskObj: musicDownloader.downloadInfos[taskId]

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
                                    // 假设 TaskId 包含了一些可读信息，或者你需要从 taskObj 获取 name
                                    text: "任务: " + taskId
                                    color: thisTheme.primaryTextColor
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    // 这里假设 taskObj 有 progress 属性 (0.0 - 1.0)
                                    // 需要在 C++ DownloadTaskThread 中添加 Q_PROPERTY
                                    text: taskObj ? Math.floor(taskObj.progress * 100) + "%" : "0%"
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
                                    width: parent.width * (taskObj ? taskObj.progress : 0)
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
                            RoundButton {
                                width: 32; height: 32
                                flat: true
                                icon.source: "qrc:/icons/pause.svg" // 请替换为你的资源路径
                                icon.color: Theme.textPrimary
                                text: "||" // 临时文本图标
                                onClicked: musicDownloader.pauseDownload(taskId)

                                ToolTip.visible: hovered
                                ToolTip.text: "暂停"
                            }

                            // 取消按钮
                            RoundButton {
                                width: 32; height: 32
                                flat: true
                                text: "X"
                                contentItem: Text {
                                    text: "×"
                                    color: thisTheme.accentColor
                                    font.pixelSize: 24
                                    anchors.centerIn: parent
                                }
                                onClicked: musicDownloader.cancelDownload(taskId)

                                ToolTip.visible: hovered
                                ToolTip.text: "取消任务"
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
