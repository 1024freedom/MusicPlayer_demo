import QtQuick 2.15

MouseArea {

    id:bottomImage
    property string source: ""
    property real imgWidth: 45
    property real imgHeight: 45


    hoverEnabled: true
    property bool hovered: false

    onClicked: {
        musicLyricPage.showPage()
    }
    onEntered: {
        hovered=true
    }
    onExited: {
        hovered=false
    }
    Image {
        id: img
        anchors.centerIn: parent
        width: parent.imgWidth
        height: parent.imgHeight
        source: parent.source
        fillMode: Image.PreserveAspectCrop//图片适配模式
    }
    Image {
        id: hintArrow
        // 箭头尺寸
        width: 30
        height: 30
        source: "qrc:/up"
        fillMode: Image.PreserveAspectFit

        // 默认隐藏，hover时显示
        visible: bottomImage.hovered
        anchors.centerIn: parent
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
        opacity: visible ? 1 : 0
        z: 10 // 确保箭头在图片上方
    }
    Rectangle{
        id:hintBack
        anchors.centerIn: parent
        width: hintArrow.width+20
        height: hintArrow.height+20
        color: "#AF000000"
        visible: bottomImage.hovered
    }




}
