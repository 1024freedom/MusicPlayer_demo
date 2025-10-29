import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:titleBar
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property string thisQml: ""
    MouseArea{

        // 允许事件传递,否则会影响鼠标拖动事件
       anchors.fill: parent
       // 允许事件传递到C++窗口
       // propagateComposedEvents: true
       // 拦截鼠标按下事件（用于窗口移动），但传递移动事件
       onPressed: {
           // 仅保证事件传递
           mouse.accepted = false;  // 不拦截，让事件传递到C++层
       }
       // // 必须显式传递鼠标移动事件
       // onMouseXChanged: {
       //     mouse.accepted = false;  // 不拦截，让事件传递到C++层
       // }
       // onMouseYChanged: {
       //     mouse.accepted = false;
       // }


        property var click_pos: Qt.point(0,0)
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
        RowLayout{
            width: parent.width-20
            height: parent.height-10
            anchors.centerIn: parent
            Row{
                width: 80
                height: parent.height
                spacing: 15
                Image {
                    width: 40
                    height: 40
                    id: topLeftIcon
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/topleft"
                }
                Text {
                    id: topLeftText
                    font.pointSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Wings of Freedom")
                    color: thisTheme.fontColor
                }
                Row{
                    width: 70
                    height: 35
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 20
                    ToolTipButtom{
                        id:pageNextMoveButton
                        // property bool isActived: false
                        width: 17
                        height: width
                        rotation: 180
                        transformOrigin: Item.Center
                        anchors.verticalCenter: parent.verticalCenter
                        source:"qrc:/next"
                        hoveredColor: thisTheme.subBackgroundColor
                        color: "#00000000"
                        onClicked: {
                            rightContent.preStep()
                        }
                    }
                    ToolTipButtom{
                        id:pagePreMoveButton
                        width: 17
                        height: width
                        transformOrigin: Item.Center
                        anchors.verticalCenter: parent.verticalCenter
                        source:"qrc:/next"
                        hoveredColor: thisTheme.subBackgroundColor
                        color: "#00000000"
                        onClicked: {
                            rightContent.nextStep()
                        }
                    }
                }

                Component.onCompleted: {
                    width=children[0].width+children[1].contentWidth+parent.spacing
                }
            }
            Item {
                Layout.fillWidth: true
            }
            Row{
                width: 30*3+5*3
                spacing: 5

                ToolTipButtom{
                    width: 17
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    source:"qrc:/theme"
                    hoveredColor: "RED"
                    onClicked: {
                        titleBar.thisQml="PageThemeChoose.qml"
                    }
                }
                Rectangle{
                    width: 30
                }

                Rectangle{
                    id:minWindowBtn
                    property bool isHovered: false
                    width: 25
                    height: 25
                    radius: 100
                    color: if(isHovered) return "#1F572920"
                            else return "#00000000"
                    Rectangle{
                        width: parent.width-5
                        height: 2
                        anchors.centerIn: parent
                        color: thisTheme.fontColor
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            window.showMinimized()
                        }
                        onEntered: {
                            parent.isHovered=true
                        }
                        onExited: {
                            parent.isHovered=false
                        }
                    }
                }
                Rectangle{
                    id:maxWindowBtn
                    property bool isHovered: false
                    width: 25
                    height: 25
                    radius: 100
                    color: if(isHovered) return "#1F572920"
                            else return "#00000000"
                    Rectangle{
                        width: parent.width-5
                        height: width
                        anchors.centerIn: parent
                        radius: 100
                        color: "#00000000"
                        border.width: 2
                        border.color: thisTheme.fontColor
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if(window.visibility===Window.Maximized){
                                window.showNormal()
                            }else{
                                window.showMaximized()
                            }
                        }
                        onEntered: {
                            parent.isHovered=true
                        }
                        onExited: {
                            parent.isHovered=false
                        }
                    }
                }
                Rectangle{
                    id:quitWindowBtn
                    property bool isHovered: false
                    width: 25
                    height: 25
                    radius: 100
                    color: if(isHovered) return "#1F572920"
                            else return "#00000000"
                    Rectangle{
                        width: parent.width-5
                        height: 2
                        anchors.centerIn: parent
                        rotation: 45
                        color: thisTheme.fontColor
                    }
                    Rectangle{
                        width: parent.width-5
                        height: 2
                        anchors.centerIn: parent
                        rotation: -45
                        color: thisTheme.fontColor
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Qt.quit()
                        }
                        onEntered: {
                            parent.isHovered=true
                        }
                        onExited: {
                            parent.isHovered=false
                        }
                    }
                }
            }
        }
    }

}
