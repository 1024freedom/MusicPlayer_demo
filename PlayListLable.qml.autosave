import QtQuick

Rectangle{
    id:playListLable
    property alias button: btn
    property alias imgSourceSize: coverImg.sourceSize
    property string imgSource: "qrc:/yy"
    property int fontSize: 11
    property string fontColor: ""
    property string normalColor: ""
    property string hoveredColor: ""
    width: 220
    height: width*1.3
    radius: 12

    signal clicked()
    signal btnClicked()

    state: "normal"//记得初始化
    states: [
        State {
                name: "normal"
                PropertyChanges {
                    target: playListLable
                    color:normalColor
                }
                PropertyChanges {
                    target: btn
                    y:btn.parent.height
                }
                PropertyChanges {
                    target: btn
                    opacity:0
                }
            },
        State {
                name: "hovered"
                PropertyChanges {
                    target: playListLable
                    color:hoveredColor
                }
                PropertyChanges {
                    target: btn
                    y:btn.parent.height-btn.height-15
                }
                PropertyChanges {
                    target: btn
                    opacity:1
                }
            }
    ]
    transitions: [
        Transition {
            from: "normal"
            to: "hovered"
            ColorAnimation {//动画效果
                target: playListLable
                easing.type:Easing.InOutQuart
                duration: 300
            }
            PropertyAnimation{
                target: btn
                property: "y"
                easing.type:Easing.InOutQuart
                duration: 300
            }
            PropertyAnimation{
                target: btn
                property: "opacity"//要动画的属性
                easing.type:Easing.InOutQuart
                duration: 300
            }
        },
        Transition {
            from: "hovered"
            to: "normal"
            ColorAnimation {
                target: playListLable
                easing.type:Easing.InOutQuart
                duration: 300
            }
            PropertyAnimation{
                target: btn
                property: "y"
                easing.type:Easing.InOutQuart
                duration: 300
            }
            PropertyAnimation{
                target: btn
                property: "opacity"
                easing.type:Easing.InOutQuart
                duration: 300
            }
        }
    ]

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            playListLable.clicked()
        }
        onEntered: {
            parent.state="hovered"
        }
        onExited: {
            parent.state="normal"
        }
        Column {
            width: parent.width-30
            height: parent.height-30
            anchors.centerIn: parent
            spacing: 20
            RoundImage{
                id:coverImg
                width: parent.width
                height: width
                imgWidth: parent.width
                imgHeight: parent.height
                radius:10
                clip: true
                source: playListLable.imgSource
                ToolTipButtom{
                    id:btn
                    width: 50
                    height: width
                    x:parent.width-width-15
                    y:parent.height
                    scale: isHovered?1.2:1.0
                    opacity: 0
                    onClicked: {
                        playListLable.btnClicked()
                    }
                    Behavior on scale{//使用state不起作用 为什么
                        PropertyAnimation{
                            target: btn
                            property: "scale"
                            easing.type:Easing.InOutQuart
                            duration: 300
                        }
                    }
                }
            }
            Text {
                width: parent.width
                height: parent.height-coverImg.height-parent.spacing
                font.pointSize: playListContent.fontSize
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                color: fontColor
                text: "精品歌单名2132333333333333333333333333333333333333333333333333333333333333"
            }
        }
    }
}
