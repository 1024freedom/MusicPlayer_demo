import QtQuick
import sz.window
import QtQuick.Layouts
import QtQuick.Controls
Rectangle{
    id:bottomBar
    property var thisTheme:p_theme.m_currentTheme
    property double fontSize: 11
    width: parent.width
    height: 80
    color: thisTheme.backgroundColor

    ThisPlayerListLabel{
        id:thisPlayerListLabel
        visible: false
        anchors.bottom: parent.top
        anchors.right: parent.right
    }

    //进度条
    Slider{
        id:bottomBarSlider
        property bool movePressed: value
        width: parent.width
        height: 5
        from: 0
        to:p_musicPlayer.duration//总时长
        anchors.bottom: parent.top
        background: Rectangle{
            color: thisTheme.subBackgroundColor
            Rectangle{
                width: bottomBarSlider.visualPosition*parent.width
                height: parent.height
                color: thisTheme.subColor
            }
        }
        handle: Rectangle{
            implicitWidth: 20
            implicitHeight: 20
            x:(bottomBarSlider.availableWidth-width)*bottomBarSlider.visualPosition
            y:-(height-bottomBarSlider.height)/2
            radius: 100
            border.width: 1.5
            border.color: thisTheme.subBackgroundColor
            color: bottomBarSlider.pressed?thisTheme.subBackgroundColor:"WHITE"
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
            enabled:bottomBarSlider.pressed===false
            function onPositionChanged(){
                bottomBarSlider.value=p_musicPlayer.position
            }
        }
    }

    Item {
        width: parent.width-15
        height: parent.height-20
        anchors.centerIn: parent
        Row{
            width: parent.width*0.3
            height: parent.height
            anchors.left: parent.left
            spacing: 10
            BottomImage{
                id:musicCoverImg
                width: parent.height
                height: width
                source:p_musicRes.thisPlayMusicInfo.coverImg 
            }
            Column{
                width: parent.width-musicCoverImg.width-parent.spacing
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id:nameText
                    width: parent.width
                    font.pointSize: bottomBar.fontSize
                    text: p_musicRes.thisPlayMusicInfo.name
                    color: thisTheme.fontColor

                    Connections{
                        target: p_musicRes
                        function onThisPlayMusicInfoChanged(){
                            nameTextAni.stop()
                            nameTextAni.lastText=p_musicRes.thisPlayMusicInfo.name
                            nameText.text=p_musicRes.thisPlayMusicInfo.name
                        }
                    }

                    NumberAnimation {//长文本滚动动画效果
                        id:nameTextAni
                        property string lastText: ""
                        target: nameText
                        property: "x"
                        to:-nameText.contentWidth/2-nameText.font.pointSize/4*3
                        duration: nameText.text.length*50
                        easing.type: Easing.Linear
                        onStopped: {
                            nameText.text=lastText
                            nameText.x=0
                            lastText=""
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            if(nameText.width<nameText.contentWidth){
                                nameTextAni.lastText=nameText.text
                                nameText.text+="   "+nameText.text
                                nameTextAni.start()
                            }
                        }
                    }
                }
                Text {
                    id:artistsText
                    width: parent.width
                    font.pointSize: bottomBar.fontSize-1
                    text: p_musicRes.thisPlayMusicInfo.artists
                    color: thisTheme.fontColor
                    Connections{
                        target: p_musicRes
                        function onThisPlayMusicInfoChanged(){
                            artistsTextAni.stop()
                            artistsTextAni.lastText=p_musicRes.thisPlayMusicInfo.artists
                            artistsText.text=p_musicRes.thisPlayMusicInfo.artists
                        }
                    }

                    NumberAnimation {//长文本滚动动画效果
                        id:artistsTextAni
                        property string lastText: ""
                        target: artistsText
                        property: "x"
                        to:-artistsText.contentWidth/2-artistsText.font.pointSize/4*3
                        duration: artistsText.text.length*50
                        easing.type: Easing.Linear
                        onStopped: {
                            artistsText.text=lastText
                            artistsText.x=0
                            lastText=""
                        }
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            if(artistsText.width<artistsText.contentWidth){
                                artistsTextAni.lastText=artistsText.text
                                artistsText.text+="   "+artistsText.text
                                artistsTextAni.start()
                            }
                        }
                    }
                }
            }
        }
        Row{
            width: parent.width*0.3
            anchors.centerIn: parent
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
        Row{
            height: 20
            anchors.right: parent.right
            anchors.verticalCenter:parent.verticalCenter
            spacing: 8
            Text {
                font.pointSize: bottomBar.fontSize
                text: p_musicRes.setTime(bottomBarSlider.value)
                font.weight: 1
                color: thisTheme.fontColor
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                font.pointSize: bottomBar.fontSize
                text: "/"+p_musicRes.thisPlayMusicInfo.allTime
                font.weight: 1
                color: thisTheme.fontColor
                anchors.verticalCenter: parent.verticalCenter
            }

            BottomBarVolumeBtn{

            }

            ToolTipButtom{
                property bool isClicked: false
                property bool isShow: false
                property var deskTopLyric: null
                width: 20
                height: width
                anchors.verticalCenter: parent.verticalCenter
                source:if(!isClicked)return "qrc:/lyricforclicked"
                            else return "qrc:/lyricclicked"
                hoveredColor: thisTheme.subBackgroundColor
                color: "#00000000"
                onClicked: {
                    isClicked=!isClicked
                    isShow=!isShow
                    var cmp=Qt.createComponent("DeskTopLyric.qml")
                    if(isShow){
                        if(cmp.status===Component.Ready){
                            deskTopLyric=cmp.createObject()
                            deskTopLyric.mediaPlayer=p_musicPlayer
                            deskTopLyric.lyricData=p_musicRes.thisPlayMusicLyric
                            deskTopLyric.show()
                        }
                    }else if(deskTopLyric){
                        deskTopLyric.destroy()
                        deskTopLyric = null
                    }
                }
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
            Component.onCompleted: {
                var w=0
                for(var i=0;i<children.length;i++){
                    if(children[i] instanceof Text){
                        w+=children[i].contentwidth
                    }else{
                        w+=children[i].width
                    }
                }
                w=w+children.length*spacing-spacing
                width=w
            }
        }
    }
}
