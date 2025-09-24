import QtQuick
//qt5模块未使用
Item {
    id:roundImage
    property alias fillMode: img.fillMode//别名
    property string source: ""
    property double radius: 10
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
        width: 45
        height: width
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
