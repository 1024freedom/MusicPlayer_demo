import QtQuick
import QtQuick.Controls

Item {
    id:musicLyricPage
    width: parent.width
    height: parent.height
    property var thisTheme: p_theme.defaultTheme[p_theme.current]

    Component.onCompleted: {
        y=parent.height

    }

    Rectangle{
        id:backGround
        anchors.fill: parent
        color:"BLACK"
    }

    MouseArea{
        id: header
        width: musicLyricPage.width
        height: 60
        property var click_pos: Qt.point(0,0)

        onPositionChanged: function(mouse){
            if(!pressed)return
            if(!window.startSystemMove()){
                var offset=Qt.point(mouseX-click_pos.x,mouseY-click_pos.y)
                window.x+=offset.x
                window.y+=offset.y
            }
        }
        onPressedChanged: function(mouse){
            click_pos=Qt.point(mouseX,mouseY)
        }
        onDoubleClicked: {
            if(window.visibility===Window.Maximized){
                window.showNormal()
            }else{
                window.showMaximized()
            }
        }

        Item {//item嵌套实现内边距
            width: parent.width-30
            height: parent.height
            anchors.centerIn: parent
            Row{
                width: 35*4+5*4
                spacing: 5
                ToolTipButtom{
                    width: 35
                    height: 35
                    source:"qrc:/detailpackup"
                    color: "#00000000"
                    hoveredColor: "#2FFFFFFF"
                    iconColor: "#FFFFFF"
                    onClicked: {
                        musicLyricPage.parent.hidePage()
                    }
                }

                Rectangle{
                    id:minWindowBtn
                    property bool isHovered: false
                    width: 35
                    height: 35
                    radius: 100
                    color: if(isHovered) return "#2FFFFFFF"
                            else return "#00000000"
                    Rectangle{
                        width: parent.width-15
                        height: 2
                        anchors.centerIn: parent
                        color: "#FFFFFF"
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            window.showMinimized()
                        }
                        onEntered: {
                            parent.isHovered=true
                        }
                        onExited: {
                            parent.isHovered=false
                        }
                    }
                }
                Rectangle{
                    id:maxWindowBtn
                    property bool isHovered: false
                    width: 35
                    height: 35
                    radius: 100
                    color: if(isHovered) return "#2FFFFFFF"
                            else return "#00000000"
                    Rectangle{
                        width: parent.width-15
                        height: width
                        anchors.centerIn: parent
                        radius: 100
                        color: "#00000000"
                        border.width: 2
                        border.color: "#FFFFFF"
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if(window.visibility===Window.Maximized){
                                window.showNormal()
                            }else{
                                window.showMaximized()
                            }
                        }
                        onEntered: {
                            parent.isHovered=true
                        }
                        onExited: {
                            parent.isHovered=false
                        }
                    }
                }
                Rectangle{
                    id:quitWindowBtn
                    property bool isHovered: false
                    width: 35
                    height: 35
                    radius: 100
                    color: if(isHovered) return "#2FFFFFFF"
                            else return "#00000000"
                    Rectangle{
                        width: parent.width-15
                        height: 2.5
                        border.color: "#FFFFFF"
                        anchors.centerIn: parent
                        rotation: 45
                        color: "#FFFFFF"
                    }
                    Rectangle{
                        width: parent.width-15
                        height: 2.5
                        border.color: "#FFFFFF"
                        anchors.centerIn: parent
                        rotation: -45
                        color: "#FFFFFF"
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Qt.quit()
                        }
                        onEntered: {
                            parent.isHovered=true
                        }
                        onExited: {
                            parent.isHovered=false
                        }
                    }
                }
            }
        }


    }
    Item {
        id: content
        width: musicLyricPage.width
        anchors.top:header.bottom
        height: musicLyricPage.height-header.height-footer.height
    }
    ThisPlayerListLabel{
        id:thisPlayerListLabel
        visible: false
        anchors.bottom: footer.top
        anchors.right: footer.right
    }
    Item {
        id: footer
        width: musicLyricPage.width
        height: 60
        anchors.top: content.bottom
        Item {
            width: parent.width-30
            height: parent.height-30
            Column {
                id:footerContent
                width: 350
                spacing: 5
                anchors.centerIn: parent
                Row{
                    id:playToolTipButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 15
                    ToolTipButtom{
                        id:playerModeIcon
                        width: 20
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        source:"qrc:/listloop"
                        hoveredColor: thisTheme.subBackgroundColor
                        color: "#00000000"
                        onClicked: {
                            p_musicPlayer.setPlayMode()
                        }

                        Connections{
                            target: p_musicPlayer
                            // ONELOOPPLAY,//单曲循环
                            // LISTLOOPPLAY,//列表循环
                            // RANDOMPLAY,//随机播放
                            // LINEPLAY//顺序播放
                            function onPlayerModeStatusChanged() {
                                switch(p_musicPlayer.playerModeStatus){
                                case MusicPlayer.PlayerMode.ONELOOPPLAY:
                                    playerModeIcon.source="qrc:/reaptSinglePlay"
                                    break
                                case MusicPlayer.PlayerMode.LISTLOOPPLAY:
                                    playerModeIcon.source="qrc:/listloop"
                                    break
                                case MusicPlayer.PlayerMode.RANDOMPLAY:
                                    playerModeIcon.source="qrc:/randomplay"
                                    break
                                case MusicPlayer.PlayerMode.LINEPLAY:
                                    playerModeIcon.source="qrc:/lineplay"
                                    break
                                }
                            }
                        }
                    }
                    ToolTipButtom{
                        width: 20
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        source:"qrc:/lastPlay"
                        hoveredColor: thisTheme.subBackgroundColor
                        color: "#00000000"
                        onClicked: {
                            p_musicPlayer.preMusicPlay()
                        }
                    }
                    ToolTipButtom{
                        width: 33
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        source:if(p_musicPlayer.playing)return "qrc:/play"
                        else return "qrc:/pause"
                        hoveredColor: thisTheme.subBackgroundColor
                        color: "#00000000"
                        onClicked: {
                            p_musicPlayer.playPauseMusic()
                        }

                        onEntered: {
                            scale=1.1
                        }
                        onExited: {
                            scale=1
                        }
                        Behavior on scale {
                            ScaleAnimator{
                                duration: 200
                                easing.type: Easing.InOutQuart
                            }
                        }
                    }
                    ToolTipButtom{
                        width: 20
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        // source:"qrc:/nextPlay"
                        source:"qrc:/lastPlay"
                        transformOrigin: Item.Center
                        rotation: 180
                        hoveredColor: thisTheme.subBackgroundColor
                        color: "#00000000"
                        onClicked: {
                            p_musicPlayer.nextMusicPlay()
                        }
                    }
                    Component.onCompleted: {
                        var w=0
                        for(var i=0;i<children.length;i++){
                            w+=children[i].width
                        }
                        w=w+children.length*spacing-spacing
                        width=w
                    }
                }
                Row {
                    width: parent.width
                    height: children[0].height
                    spacing: 5
                    Text {
                        font.pointSize: 10
                        width: contentWidth
                        height: contentHeight
                        text: "00:00"
                        color: "WHITE"
                    }
                    Slider{
                        id:footerSlider
                        property bool movePressed: value
                        width: parent.width-parent.children[0].width*2-parent.padding*2
                        anchors.verticalCenter: parent.verticalCenter
                        height: 5
                        from: 0
                        to:p_musicPlayer.duration//总时长
                        background: Rectangle{
                            color: thisTheme.subBackgroundColor
                            Rectangle{
                                width: footerSlider.visualPosition*parent.width
                                height: parent.height
                                color: "RED"
                            }
                        }
                        handle: Rectangle{
                            implicitWidth: 20
                            implicitHeight: 20
                            x:(footerSlider.availableWidth-width)*footerSlider.visualPosition
                            y:-(height-footerSlider.height)/2
                            radius: 100
                            border.width: 1.5
                            border.color: thisTheme.subBackgroundColor
                            color: footerSlider.pressed?thisTheme.subBackgroundColor:"WHITE"
                        }
                        onMoved: {
                            movePressed=true
                        }
                        onPressedChanged: {
                            if(movePressed&&!pressed){//松手后更新
                                movePressed=pressed
                                p_musicPlayer.position=value
                            }
                        }
                        Connections{
                            target: p_musicPlayer
                            enabled:footerSlider.pressed===false
                            function onPositionChanged(){
                                footerSlider.value=p_musicPlayer.position
                            }
                        }
                    }
                    Text {
                        font.pointSize: 10
                        width: contentWidth
                        height: contentHeight
                        text: "00:00"
                        color: "WHITE"
                    }
                }

            }
            Row {
                id: footerRight
                height: 20
                anchors.right: parent.right
                spacing: 15
                BottomBarVolumeBtn{

                }
                ToolTipButtom{
                    width: 20
                    height: width
                    source:"qrc:/playList"
                    hoveredColor: thisTheme.subBackgroundColor
                    color: "#00000000"
                    onClicked: {
                        thisPlayerListLabel.visible=!thisPlayerListLabel.visible
                    }
                }
            }

        }


    }

}
