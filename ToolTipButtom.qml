import QtQuick
import QtQuick.Controls
import sz.window

MouseArea{
    id:toolTipButton
    property string color: ""
    property string source: ""
    property bool isHovered: false
    property string hoveredColor: ""
    property string iconColor: ""
    property string hintText: ""
    property var thisTheme:p_theme.m_currentTheme

    width: 30
    height: width
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    Rectangle{
        anchors.fill: parent
        radius: 100
        color: if(parent.isHovered)return hoveredColor
        else return parent.color
    }
    ThemeImage{
        width: parent.width*0.5
        height: width
        anchors.fill: parent
        anchors.centerIn: parent
        source: parent.source
        color: thisTheme.accentColor
    }

    ToolTip{
        id:hintTip
        width: 60
        height: 10
        delay: 333
        x:5
        y:20
        contentItem: Text {
                    text:toolTipButton.hintText
                    font.pointSize: 8
                    font.bold: true
                    color: p_theme.m_currentTheme.disabledTextColor
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    width: parent.width
                    height: parent.height
                }
        background: Rectangle{
            anchors.fill: parent
            height: parent.height
            width: parent.width
            color:"#00000000"
        }
    }

    onEntered: {
        isHovered=true
        hintTip.visible=true
    }
    onExited: {
        isHovered=false
        hintTip.visible=false
    }
}
