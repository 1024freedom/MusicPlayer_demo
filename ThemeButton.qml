import QtQuick 2.15

Column{
    id:themeButton
    property int index: 0
    //利用index从后端拿对应的主题Map
    property var themeMap: p_theme.getM_indexofTheme(themeButton.index)
    property string hoveredColor: p_theme.m_currentTheme.itemHoverColor
    property bool isHovered: false

    MouseArea{
        id:themeIcon

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        width: 130
        height: 80
        onEntered: {
            isHovered=true
        }
        onExited: {
            isHovered=false
        }
        onClicked: {
            p_theme.setM_currentIndex(themeButton.index)
        }
        Rectangle{
            anchors.fill: parent
            radius: 10
            color:themeButton.isHovered ? themeButton.hoveredColor : "transparent"
            //如果是当前选中的主题，显示高亮框

        }

    }
    Text {
        id: themeName
        anchors.top: themeIcon.Bottom
        text: p_theme.getM_indexofTheme(themeButton.index).displayName
        color: p_theme.m_currentTheme.fontColor
        font.bold: true
        font.pointSize: 10
    }
}


