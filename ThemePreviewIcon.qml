import QtQuick 2.15

Item {
    id:root
    //接收来自c++主题的Map数据
    property var themeData: ({})
    //模拟绘制一个迷你的界面
    Rectangle{
        anchors.fill: parent;
        radius: 6
        clip: true
        border.width: 1
        border.color: "#33888888"
        Row{
            anchors.fill: parent
            //左侧模拟侧边栏
            Rectangle{
                width: parent.width*0.3
                height:parent.height
                color: root.themeData["windowBackgroundColor"]
                //侧边栏装饰
                Column{
                    anchors.centerIn: parent
                    spacing: 4
                    Repeater{
                        model: 3
                        Rectangle{
                            width: 6
                            height: 6
                            radius: 3
                            color: index===0?(root.themeData["itemSelectedColor"]):Qt.rgba(0,0,0,0.2)

                        }
                    }
                }
            }
            //右侧模拟内容区
            Rectangle{
                width: parent.width*0.7
                height: parent.height
                color: root.themeData["contentBackgroundColor"]
                Column{
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4
                    //模拟一条被选中的歌曲
                    Rectangle{
                        width: parent.width
                        height: 12
                        color: root.themeData["itemSelectedColor"]
                        radius: 2
                        Rectangle{
                            height: 2
                            width: 2
                            color: root.themeData["primaryTextColor"]
                            anchors.centerIn: parent
                        }
                    }
                    //模拟普通歌曲行
                    Rectangle{
                        width: parent.width
                        height: 12
                        color: Qt.darker(root.themeData["alternateRowColor"], 1.05) // 模拟偶数行
                                                radius: 2
                    }
                }
            }
        }
    }
}
