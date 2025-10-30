import QtQuick 2.15
import sz.window

Flickable{
    id:themeChoose
    Rectangle{
        id:content
        Row{
            id:title
            topPadding: 30
            Text {
                id: titleText
                text:"主题"
                color: p_theme.m_currentTheme.fontColor
                font.bold: true
                font.pointSize: 20
                horizontalAlignment: parent.Left
                leftPadding: 30
            }
            bottomPadding: 10
        }


        Row{
            anchors.top: title.bottom
            topPadding: 20
            padding: 10

            ThemeButton{
                index:0
                source: "qrc:/theme0.png"
            }
            ThemeButton{
                index:1
                source: "qrc:/theme1.png"
            }
            ThemeButton{
                index:2
                source: "qrc:/theme2.png"
            }
            ThemeButton{
                index:3
                source: "qrc:/theme3.png"
            }
            ThemeButton{
                index:4
                source: "qrc:/theme4.png"
            }
        }
    }
}
