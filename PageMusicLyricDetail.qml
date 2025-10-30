import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id:musicLyricPage
    width: parent.width
    height: parent.height
    property var thisTheme: p_theme.m_currentTheme
    property string backgroundColor: "BLACK"//大背景

    Component.onCompleted: {
        y=parent.height
    }

    BackgroundManager{
        id:backgroundManager
        anchors.fill: parent
        coverSource: p_musicRes.thisPlayMusicInfo.coverImg
        backgroundOpacity: 0.85
        colorCount: 3
    }
    Connections {
            target: p_musicRes
            function onThisPlayMusicInfoChanged() {
                backgroundManager.coverSource = p_musicRes.thisPlayMusicInfo.coverImg
            }
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
        Row{
            width: parent.width-30
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Item {//左侧
                id: musicInfoItem
                width: parent.width/2-parent.spacing
                height: parent.height
                Column{
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: 20
                    Item {//封面
                        id:leftContentCover
                        width: parent.width*0.5
                        height: width
                        anchors.horizontalCenter:parent.horizontalCenter
                        RoundImage{//封面图片
                            id:coverImg
                            width: parent.width
                            height: width
                            imgWidth: parent.width
                            imgHeight: imgWidth
                            source: p_musicRes.thisPlayMusicInfo.coverImg
                            sourceSize: Qt.size(400,400)
                        }
                        // 边缘淡发光效果
                        MultiEffect {
                            z:coverImg.z-1
                            anchors.fill: coverImg
                            source: coverImg
                            blurEnabled: true
                            blurMax: 70
                            blur: 0.25  // 0.0-1.0 范围
                            blurMultiplier: 1.5
                        }
                    }
                    Column{
                        width: leftContentCover.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text{//歌名文本
                            id:nameText
                            width: parent.width
                            height: contentHeight
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.Wrap
                            font.pointSize: 15
                            text: p_musicRes.thisPlayMusicInfo.name
                            color: "WHITE"
                            // layer.enabled: true
                            // layer.effect: Glow{
                            //     anchors.fill: nameText
                            //     source:nameText
                            //     samples:radius*2+1
                            //     radius:12
                            //     spread:.1
                            //      color:
                            // }需改为使用qt6
                        }
                        Text{//作曲家文本
                            id:artistsText
                            width: parent.width
                            height: contentHeight
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.Wrap
                            font.pointSize: 15
                            text: p_musicRes.thisPlayMusicInfo.artists
                            color: "WHITE"
                            // layer.enabled: true
                            // layer.effect: Glow{
                            //     anchors.fill: nameText
                            //     source:nameText
                            //     samples:radius*2+1
                            //     radius:12
                            //     spread:.1
                            // }需改为使用qt6
                        }
                        Text{//专辑文本
                            id:albumText
                            width: parent.width
                            height: contentHeight
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.Wrap
                            font.pointSize: 15
                            text: p_musicRes.thisPlayMusicInfo.album
                            color: "WHITE"
                            // layer.enabled: true
                            // layer.effect: Glow{
                            //     anchors.fill: nameText
                            //     source:nameText
                            //     samples:radius*2+1
                            //     radius:12
                            //     spread:.1
                            // }需改为使用qt6
                        }
                    }
                }
            }
            Item {//右侧内容
                width: parent.width/2-parent.spacing
                height: parent.height
                LyricListView{
                    id:lyricListView
                    width: parent.width
                    height: parent.height
                    lyricData: p_musicRes.thisPlayMusicLyric
                    mediaPlayer: p_musicPlayer
                }
            }
        }
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
            anchors.centerIn: parent
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
                        text: p_musicRes.setTime(footerSlider.value)
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
                        text: p_musicRes.setTime(p_musicRes.thisPlayMusicInfo.allTime)
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
