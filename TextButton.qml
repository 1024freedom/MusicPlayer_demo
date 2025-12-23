import QtQuick 2.15

MouseArea{
    id:toolTipButton
    property string color: ""
    property string text: ""
    property bool isHovered: false
    property string hoveredColor: ""
    property var thisTheme:p_theme.m_currentTheme


    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    Rectangle{
        anchors.fill: parent
        radius: 10
        color: if(parent.isHovered)return hoveredColor
        else return parent.color
    }

    Text {
        anchors.centerIn: parent
        text: parent.text
        color: thisTheme.accentColor
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.underline: parent.isHovered
    }
    onEntered: {
        isHovered=true
    }
    onExited: {
        isHovered=false
    }
}
