import QtQuick
//qt5模块未使用
Item {
    id:roundImage
    property alias fillMode: img.fillMode//别名
    property alias sourceSize: img.sourceSize
    property string source: ""
    property double radius: 10
    property real imgWidth: 45
    property real imgHeight: 45
    //圆角未实现
    // Rectangle{
    //     anchors.fill: parent
    //     radius: parent.radius
    //     clip: true
    //     visible: false
    //     Image {
    //         anchors.fill: parent
    //         anchors.verticalCenter: roundImage.verticalCenter
    //         width: 45
    //         height: width
    //         id: img
    //         source: roundImage.source
    //         fillMode: Image.PreserveAspectCrop//图片适配模式
    //     }
    // }
    Image {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.imgWidth
        height: parent.imgHeight
        id: img
        source: parent.source
        fillMode: Image.PreserveAspectCrop//图片适配模式
    }
    Rectangle{
        anchors.fill: parent
        visible: false
        radius: parent.radius
    }
}
