import QtQuick
//qt5模块未使用
Item {
    property alias fillMode: img.fillMode//别名
    property string source: ""
    property double radius: 10
    Image {
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
