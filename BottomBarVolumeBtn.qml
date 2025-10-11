import QtQuick
import QtQuick.Controls

MouseArea{
    width: parent.height
    height: width
    anchors.bottom: parent.bottom
    hoverEnabled: true
    state: "normal"
    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: bottomBarVolumeSliderBackground
                height:0
                opacity:0
            }
        },
        State {
            name: "hovered"
            PropertyChanges {
                target: bottomBarVolumeSliderBackground
                height:120
                opacity:1
            }
        }
    ]

    transitions: [
        Transition {
            from: "normal"
            to: "hovered"

            NumberAnimation {
                target: bottomBarVolumeSliderBackground
                property: "height"
                duration: 300
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: bottomBarVolumeSliderBackground
                property: "opacity"
                duration: 300
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "hovered"
            to: "normal"

            NumberAnimation {
                target: bottomBarVolumeSliderBackground
                property: "height"
                duration: 300
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: bottomBarVolumeSliderBackground
                property: "opacity"
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    ]

    Rectangle{
        anchors.fill: parent
    }

    onExited: {
        state="normal"
    }//注意位置

    Rectangle {id:bottomBarVolumeSliderBackground
        width: parent.width
        height: 120
        anchors.bottom: bottomBarVolumeBtn.top
        anchors.bottomMargin: 5
        radius: 12
        color: "PINK"
        Text {
            anchors.bottom: bottomBarVolumeSlider.top
            anchors.bottomMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: bottomBar.fontSize-1
            visible: bottomBarVolumeSlider.pressed
            text: p_musicRes.thisPlayMusicInfo.artists
            color: thisTheme.fontColor
        }

        Slider{
            id:bottomBarVolumeSlider
            width: 15
            height: parent.height-30
            from:0
            value: p_musicPlayer.volume
            to:1.0
            orientation: Qt.Vertical//竖向布局
            anchors.centerIn: parent
            background: Rectangle{
                color: thisTheme.subBackgroundColor
                radius: 12
                Rectangle{
                    width: parent.width
                    height: (1-bottomBarVolumeSlider.visualPosition)*parent.height
                    anchors.bottom: parent.bottom
                    radius: 12
                    color: "RED"
                }
            }
            handle: Rectangle{
                implicitWidth: 20
                implicitHeight: 20
                x:-(width-bottomBarVolumeSlider.width)/2
                y:(bottomBarVolumeSlider.availableHeight-height)*bottomBarVolumeSlider.visualPosition
                radius: 100
                border.width: 1.5
                border.color: thisTheme.subBackgroundColor
                color: bottomBarVolumeSlider.pressed?thisTheme.subBackgroundColor:"WHITE"
            }
            onMoved: {
                p_musicPlayer.lastVolume=p_musicPlayer.volume
                p_musicPlayer.volume=value
            }
        }
    }

    ToolTipButtom{
        id:bottomBarVolumeBtn
        width: 20
        height: width
        anchors.bottom: parent.bottom
        source:"qrc:/soundChanger"
        hoveredColor: thisTheme.subBackgroundColor
        color: "#00000000"
        onEntered: {
            parent.state="hovered"
        }
        onClicked: {
            if(p_musicPlayer.volume!==0){
                p_musicPlayer.volume=0
            }else{
                p_musicPlayer.volume=p_musicPlayer.lastVolume
            }
        }
    }
}
