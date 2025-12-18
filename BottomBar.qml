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
    color: thisTheme.windowBackgroundColor

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
            color: thisTheme.alternateRowColor
            Rectangle{
                width: bottomBarSlider.visualPosition*parent.width
                height: parent.height
                color: thisTheme.accentColor
            }
        }
        handle: Rectangle{
            implicitWidth: 20
            implicitHeight: 20
            x:(bottomBarSlider.availableWidth-width)*bottomBarSlider.visualPosition
            y:-(height-bottomBarSlider.height)/2
            radius: 100
            border.width: 1.5
            border.color: thisTheme.dividerColor
            color: bottomBarSlider.pressed?thisTheme.itemSelectedColor:"WHITE"
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
                width: parent.width-musicCoverImg.width-parent.spacing-100
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    id:nameText
                    width: parent.width
                    font.pointSize: bottomBar.fontSize
                    text: p_musicRes.thisPlayMusicInfo.name
                    color: thisTheme.primaryTextColor

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
                    color: thisTheme.secondaryTextColor
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
            ToolTipButtom{//添加喜欢按钮
                id:favoriteBtn
                property bool isFavorited: false
                width: 20
                height: width
                anchors.verticalCenter: parent.verticalCenter
                source:if(isFavorited)return "qrc:/favorited"
                            else return "qrc:/like"
                hoveredColor: thisTheme.itemHoverColor
                color: "#00000000"
                onClicked: {
                    if(isFavorited){
                        p_favoriteManager.remove(p_musicRes.thisPlayMusicInfo.id)
                        isFavorited=false
                    }else{
                        p_favoriteManager.append({
                                                     "id":p_musicRes.thisPlayMusicInfo.id,
                                                     "name":p_musicRes.thisPlayMusicInfo.name,
                                                     "artists":p_musicRes.thisPlayMusicInfo.artists,
                                                     "album":p_musicRes.thisPlayMusicInfo.album,
                                                     "coverImg":p_musicRes.thisPlayMusicInfo.coverImg,
                                                     "url":p_musicRes.thisPlayMusicInfo.url,
                                                     "allTime":p_musicRes.thisPlayMusicInfo.allTime
                                                 })
                        isFavorited=true
                    }
                }
                function checkFavoriteStatus() {
                    // 增加空值判断，防止刚启动时报错
                    if (!p_musicRes.thisPlayMusicInfo.id) return;

                    var index = p_favoriteManager.indexOf(p_musicRes.thisPlayMusicInfo.id)
                    favoriteBtn.isFavorited = (index !== -1)
                }

                // 1. 组件加载完成时检查一次
                Component.onCompleted: checkFavoriteStatus()

                // 2. 监听歌曲信息变化，切歌时检查
                Connections {
                    target: p_musicRes
                    function onThisPlayMusicInfoChanged() {
                        favoriteBtn.checkFavoriteStatus()
                    }
                }
            }
            DownloadButton{//下载按钮
                width: 35
                height: width
                anchors.verticalCenter: parent.verticalCenter
                songData: {
                    "id":p_musicRes.thisPlayMusicInfo.id,
                    "name":p_musicRes.thisPlayMusicInfo.name,
                    "artists":p_musicRes.thisPlayMusicInfo.artists,
                    "album":p_musicRes.thisPlayMusicInfo.album,
                    "coverImg":p_musicRes.thisPlayMusicInfo.coverImg,
                    "url":p_musicRes.thisPlayMusicInfo.url,
                    "allTime":p_musicRes.thisPlayMusicInfo.allTime
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
                hintText:"列表循环"
                hoveredColor: thisTheme.itemSelectedColor
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
                            playerModeIcon.hintText="单曲循环"
                            break
                        case MusicPlayer.PlayerMode.LISTLOOPPLAY:
                            playerModeIcon.source="qrc:/listloop"
                            playerModeIcon.hintText="列表循环"
                            break
                        case MusicPlayer.PlayerMode.RANDOMPLAY:
                            playerModeIcon.source="qrc:/randomplay"
                            playerModeIcon.hintText="随机播放"
                            break
                        case MusicPlayer.PlayerMode.LINEPLAY:
                            playerModeIcon.source="qrc:/lineplay"
                            playerModeIcon.hintText="顺序播放"
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
                hoveredColor: thisTheme.itemHoverColor
                color: "#00000000"
                hintText: "上一首"
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
                hoveredColor: thisTheme.itemHoverColor
                hintText: if(p_musicPlayer.playing)return "暂停"
                          else return "播放"
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
                hintText: "下一首"
                rotation: 180
                hoveredColor: thisTheme.itemHoverColor
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
                color: thisTheme.secondaryTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                font.pointSize: bottomBar.fontSize
                text: "/"+p_musicRes.thisPlayMusicInfo.allTime
                font.weight: 1
                color: thisTheme.secondaryTextColor
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
                hoveredColor: thisTheme.itemHoverColor
                hintText: if(!isClicked)return "开启桌面歌词"
                          else return "关闭桌面歌词"
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
                hoveredColor: thisTheme.itemHoverColor
                color: "#00000000"
                hintText: "播放队列"
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
