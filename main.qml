import QtQuick
import sz.window
import QtQuick.Layouts

FramelessWindow {
    id:window
    width: 1010
    height: 710
    minimumWidth:1010
    minimumHeight: 710
    visible: true
    title: qsTr("Hello World")

    QtObject{
        id:p_theme
        property int current: 0
        //分别为 默认主题、
        property var defaultTheme: [
            {name:"pink",type:"defult",backgroundColor:"#FAF2F1",subBackgroundColor:"#FF5966",fontColor:"#572920"}
        ]
    }

    Column{
        anchors.fill: parent

        TitleBar{
            id:titleBar
            width:parent.width
            height: 80
            color:thisTheme.backgroundColor
        }

        Rectangle{
            id:content
            width: parent.width
            height: window.height-titleBar.height-bottomBar.height
            Row{
                width: parent.width
                height: parent.height
                LeftBar{
                    id:leftBar
                    width: 180
                    height: parent.height
                }
                RightContent{
                    id:rightContent
                    width: parent.width-leftBar.width
                    height: parent.height
                }
            }
        }
        BottomBar{
            id:bottomBar
            width: parent.width
            height: 80
        }
    }



}
