import QtQuick
import QtQuick.Effects

Item {
    id: root

    // 公开属性
    property alias source: originalImg.source
    property alias sourceSize: originalImg.sourceSize
    property alias fillMode: originalImg.fillMode

    // 目标颜色
    property color color: "transparent"

    // 自动适配图片大小
    implicitWidth: originalImg.implicitWidth
    implicitHeight: originalImg.implicitHeight

    // 1. 原始图片（作为遮罩的“模具”）
    // 我们只需要它的形状（Alpha通道），不需要显示它
    Image {
        id: originalImg
        anchors.fill: parent
        visible: false
        fillMode: Image.PreserveAspectFit
    }

    // 2. 纯色块（作为“颜料”）
    // 这是我们想要显示的颜色
    Rectangle {
        id: colorRect
        anchors.fill: parent
        color: root.color
        visible: false // 隐藏，只传给 MultiEffect 用
    }

    // 3. 情况A：显示变色后的图标
    // 逻辑：用 originalImg 的形状，去剪裁 colorRect
    MultiEffect {
        anchors.fill: parent
        // 只有当颜色不透明时，才启用这个变色层
        visible: root.color.a > 0

        source: colorRect   // 源是“红纸”
        maskEnabled: true   // 开启剪刀模式
        maskSource: originalImg // 剪刀是“图标形状”
    }

    // 4. 情况B：如果没设置颜色，显示原图
    Image {
        anchors.fill: parent
        source: root.source
        sourceSize: root.sourceSize
        fillMode: root.fillMode
        // 只有当颜色是透明时，才显示原图
        visible: root.color.a === 0
    }
}
