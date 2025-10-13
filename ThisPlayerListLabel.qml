import QtQuick

Rectangle {
    width: 350
    height: 500
    anchors.bottom: parent.top
    anchors.right: parent.right
    radius: 12
    color: "#FAF2F1"

    function setHeight(children,spacing){
        var h=0
        for(var i=0;i<children.length;i++){
            if(children[i]instanceof Text){
                h+=children[i].contentHeight
            }else{
                h+=children[i].height
            }
        }
        return h+(children.length-1)*spacing
    }

    MouseArea{//捕获鼠标事件防止传递滑动
        anchors.fill: parent
        onWheel: function (mouse){

        }
    }

    ListView{
        id:thisPlayerListLabelLv
        anchors.fill: parent
        clip:true
        currentIndex: p_musicRes.thisPlayCurrent
        header: Item {
            id: header
            width: thisPlayerListLabel.width
            height: children[0].height
            Column{
                width: parent.width-40
                height: setHeight(children,spacing)+20
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12
                Text {
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.pointSize: bottomBar.fontSize+5
                    text: "当前播放:"+p_musicRes.thisPlayMusicInfo.name
                    font.weight: 1
                    color: thisTheme.fontColor
                }
                Item{
                    width: parent.width
                    height: children[0].contentHeight
                    Text {
                        font.pointSize: bottomBar.fontSize
                        text: "总共"+p_musicRes.thisPlayListInfo.count
                        font.weight: 1
                        color: thisTheme.fontColor
                    }
                    Text {
                        anchors.right: parent.right
                        font.pointSize: bottomBar.fontSize
                        text: "清空列表"
                        font.weight: 1
                        color: thisTheme.fontColor
                        MouseArea{
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                p_musicRes.thisPlayListInfo.clear()
                                p_musicRes.thisPlayMusicInfo={
                                    "id":"",
                                    "name":"",
                                    "artists":"",
                                    "album":"",
                                    "coverImg":"",
                                    "url":"",
                                    "allTime":"",
                                }
                                p_musicRes.thisPlayMusicInfoChanged()
                                p_musicRes.thisPlayCurrent=-1
                            }
                        }
                    }
                }
                Rectangle{
                    width: parent.width
                    height: 1
                    radius: width/2
                    color: thisTheme.fontColor
                }
            }
        }
        model: p_musicRes.thisPlayListInfo
        delegate: Rectangle{
            property string fontColor:if(thisPlayerListLabelLv.currentIndex===index)
                                          return thisTheme.subBackgroundColor+"FF"
                                        else return thisTheme.fontColor
            width: thisPlayerListLabel.width
            height: children[0].height+20
            color:if(index%2===0)
                      return thisTheme.subBackgroundColor
                    else return "PINK"

            Row{
                width: parent.width-40
                height: children[0].contentHeight
                anchors.centerIn: parent
                spacing: 10
                Text {
                    width: parent.width*0.3
                    font.pointSize: bottomBar.fontSize-1
                    elide: Text.ElideRight
                    color: fontColor
                    text: name
                }
                Text {
                    width: parent.width*0.2
                    font.pointSize: bottomBar.fontSize-1
                    elide: Text.ElideRight
                    color: fontColor
                    text: artists
                }
                Text {
                    width: parent.width*0.3
                    font.pointSize:bottomBar.fontSize-1
                    elide: Text.ElideRight
                    color: fontColor
                    text: album
                }
                Text {
                    width: parent.width*0.3-30
                    font.pointSize: bottomBar.fontSize-1
                    elide: Text.ElideRight
                    color: fontColor
                    text: allTime
                }
            }
            MouseArea{
                anchors.fill: parent
                onDoubleClicked: {
                    p_musicRes.thisPlayCurrent=index
                    p_musicPlayer.playMusic(id,p_musicRes.thisPlayListInfo.get(index))
                }
            }
        }
        onCurrentItemChanged: {
            if(currentItem!=null){
                thisPlayerListLabelPausePlay.parent=currentItem
            }else{
                thisPlayerListLabelPausePlay.parent=thisPlayerListLabel
            }
        }
    }
    Image{
        id:thisPlayerListLabelPausePlay
        width: 20
        height: width
        anchors.verticalCenter: parent.verticalCenter
        visible: parent!=thisPlayerListLabel
        source:if(p_musicPlayer.playbackState===1)return "qrc:/play"
                else return "qrc:/pause"
    }
    Text {
        visible: !p_musicRes.thisPlayListInfo.count
        anchors.centerIn: parent
        font.pointSize: bottomBar.fontSize+5
        text: "还未添加任何歌曲哦"
        color: thisTheme.fontColor
    }
}
