import QtQuick 2.15
import QtQuick.Effects

Item {
    id:root
    property alias source: img.source//img.source是source
    property alias sourceSize: img.sourceSize
    property alias fillMode: img.fillMode
    property string color: "transparent"
    Image {
        id: img
        anchors.fill: parent
        visible: false//始终隐藏原始图片，由Multieffect渲染
    }
    MultiEffect{
        anchors.fill: parent
        source: img
        colorization: 1.0/*root.color!="transparent"?1.0:0.0*/
        colorizationColor: root.color
    }
}
