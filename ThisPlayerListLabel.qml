import QtQuick
import QtQuick.Controls

Rectangle {
    id:thisPlayerListLabel
    width: 350
    height: 500
    radius: 12
    color: thisTheme.windowBackgroundColor

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
                    color: thisTheme.primaryTextColor
                }
                Item{
                    width: parent.width
                    height: children[0].contentHeight
                    Text {
                        font.pointSize: bottomBar.fontSize
                        text: "总共"+p_musicRes.thisPlayListInfo.count
                        font.weight: 1
                        color: thisTheme.secondaryTextColor
                    }
                    Text {
                        anchors.right: parent.right
                        font.pointSize: bottomBar.fontSize
                        text: "清空列表"
                        font.weight: 1
                        color: thisTheme.secondaryTextColor
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
                    color: thisTheme.primaryTextColor
                }
            }
        }
        model: p_musicRes.thisPlayListInfo
        delegate: Rectangle{
            property string fontColor:if(thisPlayerListLabelLv.currentIndex===index)
                                          return thisTheme.itemSelectedColor
                                        else return thisTheme.primaryTextColor
            property bool isHovered: false
            width: thisPlayerListLabel.width
            height: children[0].height+20
            color: if(isHovered)
                       return thisTheme.itemHoverColor
                        else if(index%2===0)
                            return thisTheme.alternateRowColor
                        else return thisTheme.contentBackgroundColor

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
                hoverEnabled: true
                onDoubleClicked: {
                    p_musicRes.thisPlayCurrent=index
                    p_musicPlayer.playMusic(id,p_musicRes.thisPlayListInfo.get(index))
                }
                onEntered: {
                    parent.isHovered=true
                }
                onExited: {
                    parent.isHovered=false
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
    ThemeImage{
        id:thisPlayerListLabelPausePlay
        width: 20
        height: width
        anchors.verticalCenter: parent.verticalCenter
        color:thisTheme.accentColor
        visible: parent!=thisPlayerListLabel
        source:if(p_musicPlayer.playbackState===1)return "qrc:/play"
                else return "qrc:/pause"
    }
    Text {
        visible: !p_musicRes.thisPlayListInfo.count
        anchors.centerIn: parent
        font.pointSize: bottomBar.fontSize+5
        text: "还未添加任何歌曲哦"
        color: thisTheme.disabledTextColor
    }
}
