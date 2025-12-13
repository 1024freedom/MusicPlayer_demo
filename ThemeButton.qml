import QtQuick 2.15

Column{
    id:themeButton
    property int index: 0
    //利用index从后端拿对应的主题Map
    property var themeMap: p_theme.getM_indexofTheme(themeButton.index)
    property string hoveredColor: p_theme.m_currentTheme.itemHoverColor
    property bool isHovered: false
    spacing:5

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
            border.width: p_theme.m_currentTheme.name === themeButton.themeMap["name"] ? 6 : 0
            border.color: p_theme.m_currentTheme.disabledTextColor
        }
        ThemePreviewIcon{
            anchors.centerIn: parent
            width: parent.width-16
            height: parent.height-16
            themeData: themeButton.themeMap
        }

    }
    Text {
        id: themeName
                anchors.horizontalCenter: themeIcon.horizontalCenter
        text: themeButton.themeMap["displayName"]
        color: p_theme.m_currentTheme.primaryTextColor
        font.bold: true
        font.pointSize: 10
    }
}


