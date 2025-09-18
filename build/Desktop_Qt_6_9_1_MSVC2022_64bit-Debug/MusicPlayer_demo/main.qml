import QtQuick
import sz.window

FramelessWindow {
    id:window
    width: 1010
    height: 710
    minimumWidth:1010
    minimumHeight: 710
    visible: true
    title: qsTr("Hello World")
    Column{
        anchors.fill: parent
        Rectangle{
            id:titleBar
            width:parent.width
            height: 80
            color:"RED"
            MouseArea{
                property var click_pos: Qt.point(0,0)
                anchors.fill: parent
                onPositionChanged: function(mouse){
                    if(!pressed)return
                    if(!window.startSystemMove()){
                        var offset=Qt.point(mouseX-click_pos.x,mouseY-click_pos.y)
                        window.x+=offset.x
                        window.y+=offset.y
                    }
                }
                onPressedChanged: function(mouse){
                    click_pos=Qt.point(mouseX,mouseY)
                }
                onDoubleClicked: {
                    if(window.visibility===Window.Maximized){
                        window.showNormal()
                    }else{
                        window.showMaximized()
                    }
                }
            }

        }
        Rectangle{
            id:content
            width: parent.width
            height: window.height-titleBar.height-bottomBar.height
            Row{
                width: parent.width
                height: parent.height
                Rectangle{
                    id:leftBar
                    width: 180
                    height: parent.height
                    color: "BLUE"
                }
                Rectangle{
                    id:rightContent
                    width: parent.width-leftBar.width
                    height: parent.height
                }
            }
        }
        Rectangle{
            id:bottomBar
            width: parent.width
            height: 80
            color: "RED"
        }
    }



}
