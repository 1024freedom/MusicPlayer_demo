import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    property var thisTheme: p_theme.m_currentTheme

    // 初始化时加载数据
    Component.onCompleted: {
        updateHistoryList()
    }

    // 监听后端数据变化信号
    Connections {
        target: p_history // 全局导出的 PlayHistoryManager 实例
        function onM_dataChanged() {
            updateHistoryList()
        }
    }

    // 将后端 QVariantList 转换为 QML ListModel
    function updateHistoryList() {
        var list = p_history.getRecentPlays(100) // 获取最近100条
        historyModel.clear()
        for(var i = 0; i < list.length; i++) {
            historyModel.append(list[i])
        }
        totalCountText.text = "共 " + list.length + " 首"
    }

    // --- 界面布局 ---

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. 顶部标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: thisTheme.windowBackgroundColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 30
                spacing: 10

                Text {
                    text: "最近播放"
                    font.pixelSize: 24
                    font.bold: true
                    color: thisTheme.primaryTextColor
                }

                Text {
                    id: totalCountText
                    text: "共 0 首"
                    font.pixelSize: 14
                    color: thisTheme.primaryTextColor
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 5
                }

                Item { Layout.fillWidth: true } // 占位

                // 这里可以加一个“清空全部”的按钮，如果后端支持的话
                /*
                Text {
                    text: "清空列表"
                    color: "#007AFF"
                    MouseArea { anchors.fill: parent; onClicked: p_history.clearAll() }
                }
                */
            }

            // 底部线条
            Rectangle {
                width: parent.width
                height: 1
                color: thisTheme.dividerColor
                anchors.bottom: parent.bottom
            }
        }

        // 2. 表头 (Header)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: thisTheme.contentBackgroundColor

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // 序号列
                Item { Layout.preferredWidth: 50 }

                // 标题列
                Text {
                    text: "音乐标题"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    Layout.preferredWidth: 4
                    elide: Text.ElideRight
                }

                // 歌手列
                Text {
                    text: "歌手"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    elide: Text.ElideRight
                }

                // 专辑列
                Text {
                    text: "专辑"
                    color: thisTheme.secondaryTextColor
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    elide: Text.ElideRight
                }

                // 时长列
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

        // 3. 列表内容
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel { id: historyModel }
            boundsBehavior: Flickable.StopAtBounds

            // 滚动条
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 8
            }

            delegate: Rectangle {
                id: rowDelegate
                width: listView.width
                height: 35

                // 斑马纹背景：偶数行颜色不同
                color: {
                    if (mouseArea.containsMouse) return thisTheme.itemHoverColor
                    return index % 2 === 0 ? thisTheme.contentBackgroundColor : thisTheme.alternateRowColor
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    // 双击播放
                    onDoubleClicked: {
                        // 构造符合 playMusic 要求的 musicInfo 对象
                        // Model 中的数据已经是 Map 形式，可以直接传递
                        // 注意：model 里的属性直接访问，例如 name, artists, id
                        var musicInfo = {
                            "id": id,
                            "name": name,
                            "artists": artists,
                            "album": album,
                            "coverImg": coverImg,
                            "url": url,
                            "allTime": allTime
                        }

                        // 调用你在 MediaPlayer 中定义的函数
                        p_musicPlayer.playMusic(id, musicInfo)
                        //添加到播放列表


                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 1. 序号 (01, 02...)
                    Text {
                        Layout.preferredWidth: 50
                        text: (index + 1).toString().padStart(2, '0')
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignCenter
                    }

                    // 2. 歌曲名称
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 4
                        text: name
                        color: thisTheme.primaryTextColor
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        Layout.rightMargin: 10
                    }

                    // 3. 歌手
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        text: artists
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        Layout.rightMargin: 10
                    }

                    // 4. 专辑
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        text: album
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        Layout.rightMargin: 10
                    }

                    // 5. 时长
                    Text {
                        Layout.preferredWidth: 80
                        text: allTime
                        color: thisTheme.secondaryTextColor
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignRight
                        rightPadding: 20
                    }
                }
            }
        }
    }
}
