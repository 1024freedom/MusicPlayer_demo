import QtQuick 2.15
import QtQuick.Controls 2.15
import sz.window

Rectangle{
    anchors.fill: parent
    color: p_theme.m_currentTheme.contentBackgroundColor
    Flickable{
        id:themeChoose
        anchors.fill: parent//必须要有尺寸才能显示
        contentHeight: content.height//确保flickable能正常滚动
        clip:true

        Rectangle{
            id:content
            width:parent.width
            //高度自适应内容
            height: title.height+themeFlow.height+50
            color: "transparent"
            Row{
                id:title
                topPadding: 30
                width: parent.width

                Text {
                    id: titleText
                    text:"主题"
                    color: p_theme.m_currentTheme.primaryTextColor
                    font.bold: true
                    font.pointSize: 20
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 30
                }
                bottomPadding: 10
            }
            Rectangle{
                id:line
                anchors.top: title.bottom
                anchors.topMargin: 10
                width: parent.width
                height: 2
                color: p_theme.m_currentTheme.dividerColor
            }

            //使用Flow自动流式布局，可自动换行
            Flow{
                id:themeFlow
                anchors.top: line.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 30
                spacing:20//按钮之间的间距
                Repeater{
                    model: p_theme.m_themes
                    ThemeButton{
                        index: model.index
                    }
                }
            }
        }
    }

}

