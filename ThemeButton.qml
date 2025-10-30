import QtQuick 2.15

MouseArea{
    property string hoveredColor: p_theme.m_currentTheme.subBackgroundColor
    property bool isHovered: false
    property int index: 0
    property string source: ""
    property string color: "WHITE"
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    width: 150
    height: 80
    onEntered: {
        isHovered=true
    }
    onExited: {
        isHovered=false
    }
    onClicked: {
        p_theme.setM_currentIndex(index)
    }
    Rectangle{
        anchors.fill: parent
        radius: 20
        color:if(parent.isHovered) return parent.hoveredColor
              else return parent.color
    }
    Image {
        width: parent.width*0.5
        height: width
        anchors.fill: parent
        anchors.centerIn: parent
        source: parent.source
    }
    Text {
        id: themeName
        horizontalAlignment: parent.BottomLeft
        text: p_theme.getM_indexofTheme(index).displayName
        font.bold: true
        font.pointSize: 10
    }
}
