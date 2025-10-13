import QtQuick

MouseArea{
    property string color: ""
    property string source: ""
    property bool isHovered: false
    property string hoveredColor: ""
    property string iconColor: ""
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
    Image {
        width: parent.width*0.5
        height: width
        anchors.fill: parent
        anchors.centerIn: parent
        source: parent.source
    }
    onEntered: {
        isHovered=true
    }
    onExited: {
        isHovered=false
    }
}
