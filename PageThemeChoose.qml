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
            }
            ThemeButton{
                index:1
            }
            ThemeButton{
                index:2
            }
            ThemeButton{
                index:3
            }
            ThemeButton{
                index:4
            }
        }
    }
}
