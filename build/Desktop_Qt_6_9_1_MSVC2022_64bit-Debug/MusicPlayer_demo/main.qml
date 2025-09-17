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
        }

    }
}
