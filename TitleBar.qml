import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:titleBar
    property var thisTheme: p_theme.m_currentTheme
    property string thisQml: ""
    property string searchKeyword: ""

    RowLayout{
        width: parent.width-20
        height: parent.height-10
        anchors.centerIn: parent
        spacing: 0
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
                font.pointSize: 17
                font.bold: true
                font.family: "Brush Script MT"
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Music Of Freedom")
                color: thisTheme.accentColor
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
                    hoveredColor: thisTheme.itemHoverColor
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
                    hoveredColor: thisTheme.itemHoverColor
                    color: "#00000000"
                    onClicked: {
                        rightContent.nextStep()
                    }
                }
                TitleBarSearchBox{

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
            width: 250
            spacing: 5
            property bool themeVisible: false
            ToolTipButtom{
                width: 17
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                source:"qrc:/theme"
                hintText: "主题"
                hoveredColor: thisTheme.itemHoverColor
                color: "#00000000"
                onClicked: {
                    if(!parent.themeVisible){
                        titleBar.thisQml="PageThemeChoose.qml"
                        parent.themeVisible=!parent.themeVisible
                    }else{
                        titleBar.thisQml=""
                        parent.themeVisible=!parent.themeVisible
                    }
                }
                anchors.rightMargin: 20
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
                color: if(isHovered) return thisTheme.itemHoverColor
                        else return "#00000000"
                Rectangle{
                    width: parent.width-5
                    height: 2
                    anchors.centerIn: parent
                    color: thisTheme.accentColor
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
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
                color: if(isHovered) return thisTheme.itemHoverColor
                        else return "#00000000"
                Rectangle{
                    width: parent.width-5
                    height: width
                    anchors.centerIn: parent
                    radius: 100
                    color: "#00000000"
                    border.width: 2
                    border.color: thisTheme.accentColor
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
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
                color: if(isHovered) return thisTheme.itemHoverColor
                        else return "#00000000"
                Rectangle{
                    width: parent.width-5
                    height: 2
                    anchors.centerIn: parent
                    rotation: 45
                    color: thisTheme.accentColor
                }
                Rectangle{
                    width: parent.width-5
                    height: 2
                    anchors.centerIn: parent
                    rotation: -45
                    color: thisTheme.accentColor
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
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
