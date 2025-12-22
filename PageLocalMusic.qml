import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform 1.1 // 用于文件夹选择

Item {
    id: root
    anchors.fill: parent

    property var thisTheme: p_theme.m_currentTheme

    // --- 0. 逻辑控制区域 ---

    // 文件夹选择弹窗
    FolderDialog {
        id: folderDialog
        title: "选择本地音乐文件夹"
        onAccepted: {
            p_localmusicManager.scanDirectory(folder)
        }
    }

    // 初始化加载
    Component.onCompleted: {
        updateMusicList()
    }

    // 监听后端数据变化
    Connections {
        target: p_localmusicManager
        function onDataChanged() {
            updateMusicList()
        }
    }

    // 数据转换与刷新
    function updateMusicList() {
        var list = p_localmusicManager.data
        musicModel.clear()
        for(var i = 0; i < list.length; i++) {
            musicModel.append(list[i])
        }
        totalCountText.text = "共 " + list.length + " 首"
    }

    // --- 1. 界面布局 ---

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // === 顶部标题栏 ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60 // 稍微加高一点以容纳按钮
            color: thisTheme.windowBackgroundColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 30
                anchors.rightMargin: 30
                spacing: 15

                Text {
                    text: "本地音乐"
                    font.pixelSize: 24
                    font.bold: true
                    color: thisTheme.primaryTextColor
                }

                Text {
                    id: totalCountText
                    text: "共 0 首"
                    font.pixelSize: 14
                    color: thisTheme.secondaryTextColor
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 5
                }

                Item { Layout.fillWidth: true } // 占位符

                // --- 顶部按钮组 ---

                // 1. 播放全部按钮
                Button {
                    text: "播放全部"
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 100

                    contentItem: Text {
                        text: parent.text
                        color: thisTheme.accentColor
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: if(parent.down)return Qt.darker(thisTheme.itemSelectedColor)
                        else if(parent.hovered)return thisTheme.itemHoverColor
                        else return thisTheme.itemSelectedColor
                        radius: 15
                    }
                    onClicked: {
                        // TODO: 播放列表所有歌曲逻辑
                    }
                }

                // 2. 选择目录按钮
                Button {
                    text: "选择目录"
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 80
                    onClicked: folderDialog.open()

                    contentItem: Text {
                        text: parent.text
                        color: thisTheme.itemSelectedColor // 使用主题色作为文字颜色
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.underline: parent.hovered // 悬停下划线
                    }
                    background: Item {} // 透明背景
                }
            }

            // 底部线条
            Rectangle {
                width: parent.width
                height: 1
                color: thisTheme.dividerColor
                anchors.bottom: parent.bottom
            }
        }

        // === 表头 (Header) ===
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: thisTheme.contentBackgroundColor

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // 定义列宽策略：
                // 序号: 50px
                // 标题: 权重 4
                // 歌手: 权重 2
                // 专辑: 权重 2
                // 大小: 80px
                // 时长: 80px

                Item { Layout.preferredWidth: 50 } // 序号

                Text {
                    text: "音乐名"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.fillWidth: true; Layout.preferredWidth: 4
                    elide: Text.ElideRight
                    leftPadding: 10
                }
                Text {
                    text: "歌手"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.fillWidth: true; Layout.preferredWidth: 2
                    elide: Text.ElideRight
                    leftPadding: 10
                }
                Text {
                    text: "专辑"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.fillWidth: true; Layout.preferredWidth: 2
                    elide: Text.ElideRight
                    leftPadding: 10
                }
                Text {
                    text: "大小"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.preferredWidth: 80
                    leftPadding: 10
                }
                Text {
                    text: "时长"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight
                    rightPadding: 20
                }
            }
        }

        // === 列表内容 (ListView) ===
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel { id: musicModel }
            boundsBehavior: Flickable.StopAtBounds

            // 滚动条
            ScrollBar.vertical: ScrollBar {
                id: vbar
                policy: ScrollBar.AsNeeded
                width: 10
                contentItem: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 100
                    radius: width / 2
                    color: vbar.pressed ? thisTheme.itemSelectedColor
                                        : Qt.rgba(thisTheme.primaryTextColor.r,
                                                  thisTheme.primaryTextColor.g,
                                                  thisTheme.primaryTextColor.b,
                                                  0.5)
                    opacity: vbar.active || vbar.pressed ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }

            delegate: Rectangle {
                id: rowDelegate
                width: listView.width
                height: 35

                // 颜色逻辑：选中 > 悬停 > 斑马纹
                color: {
                    if (listView.currentIndex === index) return thisTheme.itemSelectedColor
                    if (mouseArea.containsMouse) return thisTheme.itemHoverColor
                    return index % 2 === 0 ? thisTheme.contentBackgroundColor : thisTheme.alternateRowColor
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: listView.currentIndex = index

                    onDoubleClicked: {
                        // 构造播放数据对象 (键名需与 C++ 这里提取的一致)
                        var musicInfo = {
                            "id": model.path, // 本地音乐通常用路径做 ID
                            "name": model.name,
                            "artists": model.artists, // 注意 C++ 那边如果是 "artist"
                            "album": model.album,
                            "url": "file://" + model.path, // 本地文件需加协议头
                            "duration": model.duration,
                            "coverImg": "qrc:/images/default_cover.png" // 本地音乐暂无封面，给个默认图
                        }

                        // 调用播放接口 需要增加一个使用路径而不是id的重载方法
                        p_musicPlayer.playMusic(model.path, musicInfo)
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 1. 序号
                    Text {
                        Layout.preferredWidth: 50
                        text: (index + 1).toString().padStart(2, '0')
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignCenter
                    }

                    // 2. 名
                    Text {
                        Layout.fillWidth: true; Layout.preferredWidth: 4
                        text: model.name
                        color: thisTheme.primaryTextColor
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        leftPadding: 10
                        Layout.rightMargin: 10
                    }

                    // 3. 歌手
                    Text {
                        Layout.fillWidth: true; Layout.preferredWidth: 2
                        text: model.artists
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        leftPadding: 10
                        Layout.rightMargin: 10
                    }

                    // 4. 专辑
                    Text {
                        Layout.fillWidth: true; Layout.preferredWidth: 2
                        text: model.album
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        leftPadding: 10
                        Layout.rightMargin: 10
                    }

                    // 5. 大小 (本地音乐特有)
                    Text {
                        Layout.preferredWidth: 80
                        text: model.size
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        leftPadding: 10
                        elide: Text.ElideRight
                    }

                    // 6. 时长
                    Text {
                        Layout.preferredWidth: 80
                        text: model.duration
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignRight
                        rightPadding: 20
                    }
                }
            }
        }
    }

    // === 全局加载遮罩 (Loading Spinner) ===
    // 覆盖在最上层，当后端扫描时显示
    Rectangle {
        anchors.fill: parent
        color: "#80FFFFFF" // 半透明遮罩
        visible: p_localmusicManager.isLoading
        z: 999

        Column {
            anchors.centerIn: parent
            spacing: 15

            BusyIndicator {
                running: parent.visible
                anchors.horizontalCenter: parent.horizontalCenter
                // 尝试适配主题色
                // palette.dark: thisTheme.itemSelectedColor
            }

            Text {
                text: "正在扫描本地文件..."
                color: thisTheme.itemSelectedColor
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // 拦截鼠标事件，防止扫描时用户操作
        MouseArea { anchors.fill: parent }
    }
}
