import QtQuick 2.15

Column{
    id:themeButton
    property int index: 0
    property string hoveredColor: p_theme.m_currentTheme.subBackgroundColor
    property bool isHovered: false
    property string source: ""
    property string color: "WHITE"
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
            color:if(themeButton.isHovered) return themeButton.hoveredColor
                  else return themeButton.color
        }
        Image {
            width: parent.width*0.5
            height: width
            anchors.fill: parent
            anchors.centerIn: parent
            source: themeButton.source
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


