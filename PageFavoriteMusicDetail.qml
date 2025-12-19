import QtQuick
import QtQuick.Controls
ListView {
    id: favoriteMusicDetail
    property var thisTheme: p_theme.m_currentTheme
    property var playListInfo: null
    property int fontSize: 11
    width: parent.width
    height: parent.height

    currentIndex: -1
    clip: true

    Toast{
        id:toast
    }

    onCountChanged: {
        contentItemBackground.height=count*80+30
    }

    function setHeight(children,spacing){//用于将头部与内容部分分离
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


    // 滚动条
    ScrollBar.vertical: ScrollBar {
        id: vbar
        policy: ScrollBar.AsNeeded
        width: 10

        // 自定义滑块
        contentItem: Rectangle {
            implicitWidth: parent.width
            implicitHeight: 100
            radius: width / 2

            // 颜色逻辑：
            // 按下时 -> 使用主题的强调色
            // 平时   -> 使用主题文字颜色的半透明版 (保证在任何背景下都能看见)
            color: vbar.pressed ? p_theme.m_currentTheme.itemSelectedColor
                                : Qt.rgba(p_theme.m_currentTheme.primaryTextColor.r,
                                          p_theme.m_currentTheme.primaryTextColor.g,
                                          p_theme.m_currentTheme.primaryTextColor.b,
                                          0.5) // 0.5 透明度，既明显又不遮挡太多

            //简单的悬停变暗效果
            opacity: vbar.active || vbar.pressed ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    header: Item {
        id: header
        property string id: ""
        property string nameText: "我的收藏"
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
                        font.pointSize: favoriteMusicDetail.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.itemSelectedColor
                        text: "歌单"
                    }
                    Text {
                        width: parent.width
                        font.pointSize: 20
                        elide: Text.ElideRight
                        color: thisTheme.primaryTextColor
                        text: header.nameText
                    }
                    Text {
                        width: parent.width
                        font.pointSize: favoriteMusicDetail.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.secondaryTextColor
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
                    hoveredColor: thisTheme.itemHoverColor
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
                    hoveredColor: thisTheme.itemHoverColor
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
                    color: thisTheme.secondaryTextColor
                    text: "序号"
                }
                Text {
                    width: parent.width*0.3
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize:fontSize
                    elide: Text.ElideRight
                    color: thisTheme.primaryTextColor
                    text: "歌名"
                }
                Text {
                    width: parent.width*0.25
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.secondaryTextColor
                    text: "作者"
                }
                Text {
                    width: parent.width*0.2
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.secondaryTextColor
                    text: "专辑"
                }
                Text {
                    width: parent.width*0.1
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.secondaryTextColor
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
        Component.onCompleted: {
            var data=p_favoriteManager.data
            for(var i=0;i<data.length;i++){
                append(data[i])
            }

            favoriteMusicDetail.headerItem.coverImg=contentListModel.get(0).coverImg//第一首歌的coverimg作为头图

        }
    }

    delegate: Rectangle{
        property bool isHovered: false
        width: favoriteMusicDetail.width-80
        height: 80
        radius: 12
        color: if(currentIndex===index)
                   return thisTheme.itemSelectedColor
                else if(isHovered) return thisTheme.itemHoverColor
                else if(index%2===0) return thisTheme.alternateRowColor
        else return thisTheme.contentBackgroundColor
        onParentChanged: {
            if(parent!=null){
                anchors.horizontalCenter=parent.horizontalCenter
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
                var findIndex=p_musicRes.indexOf(id)
                if(findIndex===-1){
                    for(var i=0;i<contentListModel.count;i++){
                        p_musicRes.thisPlayListInfo.append(contentListModel.get(i))
                    }
                    p_musicRes.thisPlayListInfoChanged()
                    p_musicRes.thisPlayCurrent+=1
                }else{
                    p_musicRes.thisPlayCurrent=findIndex
                }

                p_musicPlayer.playMusic(id,musicInfo)
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
            Row{
                width: parent.width-20
                height: 30
                anchors.centerIn: parent
                spacing: 10

                Row{
                    width: parent.width*0.15-40
                    height: 35
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.weight: 2
                        font.pointSize:fontSize
                        elide: Text.ElideRight
                        color: thisTheme.secondaryTextColor
                        text: index+1
                    }
                    ToolTipButtom{//添加喜欢按钮
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
                                p_favoriteManager.remove(model.id)
                                isFavorited=false
                            }else{
                                p_favoriteManager.append(contentListModel.get(index))
                                isFavorited=true
                            }
                        }
                        Component.onCompleted: {
                            var index=p_favoriteManager.indexOf(id)
                            isFavorited=(index!==-1)
                        }
                    }
                }
                Text {
                    width: parent.width*0.3
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize:fontSize
                    elide: Text.ElideRight
                    color: thisTheme.primaryTextColor
                    text: model.name
                }
                Text {
                    width: parent.width*0.25
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.secondaryTextColor
                    text: model.artists
                }
                Text {
                    width: parent.width*0.2
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.secondaryTextColor
                    text: model.album
                }
                Text {
                    width: parent.width*0.1-30
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.weight: 2
                    font.pointSize: fontSize
                    elide: Text.ElideRight
                    color: thisTheme.secondaryTextColor
                    text: model.allTime
                }
                DownloadButton{
                    id:downloadButton
                    width: 25
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    songData: {
                        "id":id,
                        "name":name,
                        "artists":artists,
                        "album":album,
                        "coverImg":coverImg,
                        "url":url,
                        "allTime":allTime
                    }
                    onError: (msg)=>{
                                toast.show(msg)
                             }
                }
            }

        }
    }
    Rectangle{
        id:contentItemBackground
        parent: favoriteMusicDetail.contentItem
        color: thisTheme.contentBackgroundColor
        y:-15
        width: favoriteMusicDetail.width-50
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 12
    }

}
