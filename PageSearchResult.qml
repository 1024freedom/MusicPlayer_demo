import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: searchResultPage
    anchors.fill: parent
    color: theme.backgroundColor

    // 接收外部传入的搜索关键字
    property string searchKeyword: ""

    // ---------------- 主题颜色管理 ----------------
    QtObject {
        id: theme
        property color primaryColor: "#EC4141"      // 网易云红
        property color backgroundColor: "#FFFFFF"   // 背景白
        property color hoverColor: "#F2F2F3"        // 列表悬停灰
        property color headerColor: "#FAFAFA"       // 表头灰
        property color textColor: "#333333"         // 主文字
        property color subTextColor: "#888888"      // 副文字
        property color dividerColor: "#E0E0E0"      // 分割线
    }

    // ---------------- 逻辑控制 ----------------
    Component.onCompleted: {
        // 页面加载时如果已有关键字，立即搜索单曲
        if(searchKeyword !== "") {
            loadData(1)
        }
    }

    onSearchKeywordChanged: {
        loadData(currentType)
    }

    property int currentType: 1 // 1: 单曲, 1000: 歌单

    function loadData(type) {
        currentType = type
        loadingIndicator.running = true

        // 调用 C++ 接口
        musicSearch.search({
            "keywords": searchKeyword,
            "type": type.toString(),
            "callBack": function(result) {
                loadingIndicator.running = false
                if (type === 1) {
                    songsModel.clear()
                    for (var i = 0; i < result.length; i++) {
                        songsModel.append(result[i])
                    }
                } else if (type === 1000) {
                    playlistsModel.clear()
                    for (var j = 0; j < result.length; j++) {
                        playlistsModel.append(result[j])
                    }
                }
            }
        })
    }

    // ---------------- 界面布局 ----------------
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. 顶部标题
        Text {
            Layout.topMargin: 20
            Layout.leftMargin: 30
            text: "搜索 \"" + searchKeyword + "\""
            font.pixelSize: 20
            font.bold: true
            color: theme.textColor
        }

        // 2. Tab 切换栏
        Row {
            Layout.topMargin: 20
            Layout.leftMargin: 30
            Layout.bottomMargin: 10
            spacing: 30

            Repeater {
                model: [
                    { name: "单曲", type: 1 },
                    { name: "歌单", type: 1000 }
                ]
                delegate: MouseArea {
                    width: tabText.implicitWidth
                    height: 30
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (currentType !== modelData.type) {
                            loadData(modelData.type)
                        }
                    }

                    Text {
                        id: tabText
                        text: modelData.name
                        font.pixelSize: 16
                        font.bold: currentType === modelData.type
                        color: currentType === modelData.type ? theme.textColor : theme.subTextColor
                    }

                    // 选中下划线
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.8
                        height: 3
                        color: theme.primaryColor
                        visible: currentType === modelData.type
                    }
                }
            }
        }

        // 3. 内容区域 (StackLayout 切换视图)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // 加载动画
            BusyIndicator {
                id: loadingIndicator
                anchors.centerIn: parent
                running: false
                z: 10
            }

            // 单曲列表视图
            ListView {
                id: songListView
                anchors.fill: parent
                visible: currentType === 1
                model: ListModel { id: songsModel }

                // 表头
                header: Rectangle {
                    width: parent.width
                    height: 36
                    color: theme.headerColor
                    RowLayout {
                        anchors.fill: parent
                        spacing: 0
                        Item { width: 50 } // 序号占位
                        Text { Layout.fillWidth: true; Layout.preferredWidth: 4; text: "音乐标题"; color: theme.subTextColor; font.pixelSize: 13 }
                        Text { Layout.fillWidth: true; Layout.preferredWidth: 2; text: "歌手"; color: theme.subTextColor; font.pixelSize: 13 }
                        Text { Layout.fillWidth: true; Layout.preferredWidth: 2; text: "专辑"; color: theme.subTextColor; font.pixelSize: 13 }
                        Text { width: 80; text: "时长"; color: theme.subTextColor; font.pixelSize: 13; horizontalAlignment: Text.AlignRight; rightPadding: 20}
                    }
                }

                delegate: Rectangle {
                    width: parent.width
                    height: 36
                    color: index % 2 === 0 ? theme.backgroundColor : "#FAFAFA" // 斑马纹

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = theme.hoverColor
                        onExited: parent.color = (index % 2 === 0 ? theme.backgroundColor : "#FAFAFA")
                        // 双击播放逻辑
                        onDoubleClicked: console.log("Play song id: " + model.id)
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        // 序号
                        Text {
                            width: 50
                            text: (index + 1).toString().padStart(2, '0')
                            color: theme.subTextColor
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 13
                        }

                        // 歌名
                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 4
                            text: model.name
                            color: theme.textColor
                            elide: Text.ElideRight
                            font.pixelSize: 13
                        }

                        // 歌手
                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 2
                            text: model.artists
                            color: theme.subTextColor
                            elide: Text.ElideRight
                            font.pixelSize: 13
                        }

                        // 专辑
                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 2
                            text: model.album
                            color: theme.subTextColor
                            elide: Text.ElideRight
                            font.pixelSize: 13
                        }

                        // 时长
                        Text {
                            width: 80
                            text: model.allTime
                            color: theme.subTextColor
                            horizontalAlignment: Text.AlignRight
                            rightPadding: 20
                            font.pixelSize: 13
                        }
                    }
                }
                ScrollBar.vertical: ScrollBar {}
            }

            // 歌单列表视图
            GridView {
                id: playlistView
                anchors.fill: parent
                anchors.margins: 20
                visible: currentType === 1000
                cellWidth: width / 5 // 一行5个
                cellHeight: cellWidth + 50
                model: ListModel { id: playlistsModel }
                clip: true

                delegate: Item {
                    width: playlistView.cellWidth
                    height: playlistView.cellHeight

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        spacing: 8

                        // 封面
                        Rectangle {
                            width: parent.width
                            height: width
                            radius: 5
                            color: "#E0E0E0"
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: model.coverImg
                                fillMode: Image.PreserveAspectCrop
                            }

                            // 播放量遮罩
                            Rectangle {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                width: parent.width
                                height: 20
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#66000000" }
                                    GradientStop { position: 1.0; color: "#00000000" }
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 5
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "▷ " + (model.playCount > 10000 ? (model.playCount/10000).toFixed(1)+"万" : model.playCount)
                                    color: "white"
                                    font.pixelSize: 10
                                }
                            }
                        }

                        // 歌单名
                        Text {
                            width: parent.width
                            text: model.name
                            color: theme.textColor
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                        }

                        // 创建者
                        Text {
                            text: "by " + model.creator
                            color: theme.subTextColor
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: console.log("Open playlist id: " + model.id)
                    }
                }
                ScrollBar.vertical: ScrollBar {}
            }
        }
    }
}
