import QtQuick

ListView {
    id: playListDetail
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property var playListInfo: null
    property int fontSize: 11
    width: parent.width
    height: parent.height

    currentIndex: -1
    clip: true

    onPlayListInfoChanged: {
        headerItem.id=playListInfo.id
        headerItem.nameText=playListInfo.name
        headerItem.coverImg=playListInfo.coverImg
        headerItem.descriptionText=playListInfo.description

        var musicDetailCallBack=res=>{
            contentListModel.append(res)
            console.log(JSON.stringify(res[0]))
        }

        var musicPlayDetailCallBack=res=>{
            var ids=res.trackIds.join(',')
            console.log(JSON.stringify(res))
            p_musicRes.getMusicDetail({ids:ids,callBack:musicDetailCallBack})
        }

        p_musicRes.getMusicPlayListDetail({id:playListInfo.id,callBack:musicPlayDetailCallBack})
    }

    onCountChanged: {
        contentItemBackground.height=count*80+30
    }

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


    header: Item {
        id: header
        property string id: ""
        property string nameText: ""
        property string coverImg: ""
        property string descriptionText: ""
        width: parent.width-60
        height: children[0].height+50
        anchors.horizontalCenter: parent.horizontalCenter
        Column{
            width: parent.width
            height: setHeight(children,spacing)
            anchors.top: parent.top
            anchors.topMargin: 30
            spacing: 15
            Row{
                width: parent.width
                height: 200
                spacing: 15
                RoundImage{
                    id:coverImg
                    width: parent.height
                    height: width
                    imgWidth: width
                    imgHeight: height
                    source:header.coverImg
                }
                Column{
                    width: parent.width-coverImg.width-parent.spacing
                    height: setHeight(children,spacing)
                    anchors.verticalCenter: coverImg.verticalCenter
                    spacing: 15
                    Text {
                        width: parent.width
                        font.pointSize: playListDetail.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.subBackgroundColor
                        text: "歌单"
                    }
                    Text {
                        width: parent.width
                        font.pointSize: 20
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: header.nameText
                    }
                    Text {
                        width: parent.width
                        font.pointSize: playListDetail.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: header.descriptionText
                    }
                }
            }
            Row{
                width: parent.width
                height: 50
                spacing: 15
                ToolTipButtom{
                    width: 34
                    height: width
                    source:"qrc:/pause"
                    hoveredColor: thisTheme.subBackgroundColor
                    color: "#00000000"
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
                    width: 33
                    height: width
                    source:"qrc:/playList"
                    hoveredColor: thisTheme.subBackgroundColor
                    color: "#00000000"
                }

            }
            Row{
                width: parent.width-40
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Text {
                    width: parent.width*0.15-40
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.weight: 2
                    font.pointSize:fontSize
                    elide: Text.ElideRight
                    color: thisTheme.fontColor
                    text: "序号"
                }
                Text {
                    width: parent.width*0.3
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize:fontSize
                    elide: Text.ElideRight
                    color: thisTheme.fontColor
                    text: "歌名"
                }
                Text {
                    width: parent.width*0.25
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.fontColor
                    text: "作者"
                }
                Text {
                    width: parent.width*0.2
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.fontColor
                    text: "专辑"
                }
                Text {
                    width: parent.width*0.1
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.fontColor
                    text: "时长"
                }
            }
        }
    }

    footer: Rectangle{//视觉缓冲 平衡布局
        width: parent.width-80
        height: 50
        color: "#00000000"
    }

    model: ListModel{
        id:contentListModel
    }

    delegate: Rectangle{
        property bool isHovered: false
        width: playListDetail.width-80
        height: 80
        radius: 12
        color: if(currentIndex===index)
                   return thisTheme.subBackgroundColor
                else if(isHovered) return thisTheme.subBackgroundColor
                else return "#00000000"
        onParentChanged: {
            if(parent!=null){
                anchors.horizontalCenter=parent.horizontalCenter
            }
        }
        Row{
            width: parent.width-20
            height: 30
            anchors.centerIn: parent
            spacing: 10
            Text {
                width: parent.width*0.15-40
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                font.weight: 2
                font.pointSize:fontSize
                elide: Text.ElideRight
                color: thisTheme.fontColor
                text: index+1
            }
            Text {
                width: parent.width*0.3
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                font.weight: 2
                font.pointSize:fontSize
                elide: Text.ElideRight
                color: thisTheme.fontColor
                text: name
            }
            Text {
                width: parent.width*0.25
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                font.weight: 2
                font.pointSize: fontSize
                elide: Text.ElideRight
                color: thisTheme.fontColor
                text: artists
            }
            Text {
                width: parent.width*0.2
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                font.weight: 2
                font.pointSize: fontSize
                elide: Text.ElideRight
                color: thisTheme.fontColor
                text: album
            }
            Text {
                width: parent.width*0.1
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                font.weight: 2
                font.pointSize: fontSize
                elide: Text.ElideRight
                color: thisTheme.fontColor
                text: allTime
            }
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onDoubleClicked: {
                var musicInfo={id:id,name:name,artists:artists,
                                album:album,coverImg:coverImg,url:"",
                                allTime:allTime
                }
                p_musicPlayer.playMusic(id,musicInfo)

                p_musicRes.thisPlayListInfo.clear()
                for(var i=0;i<contentListModel.count;i++){
                    p_musicRes.thisPlayListInfo.append(contentListModel.get(i))
                }
                p_musicRes.thisPlayCurrent=index
                console.log("当前播放列表"+JSON.stringify(p_musicRes.thisPlayListInfo.get(0)))
            }
            onClicked: {
                currentIndex=index
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
        id:contentItemBackground
        parent: playListDetail.contentItem
        y:-15
        width: playListDetail.width-50
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 12
    }

}
