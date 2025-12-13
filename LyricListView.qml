import QtQuick
import QtMultimedia

Item {
    id:lyricListView
    width: parent.width
    height: parent.height
    property var thisTheme: p_theme.m_currentTheme
    property ListModel lyricData:ListModel{}
    property int current: -1
    property int delayTime: 10000
    property MediaPlayer mediaPlayer: MediaPlayer{}
    property bool isFollowed: true//歌词显示是否跟随歌曲进度

    onCurrentChanged: {
        if(isFollowed){
            listView.currentIndex=current
        }
    }

    function offsetScale(index,currentIndex){//字体缩放
        var offset=Math.abs(index-currentIndex)
        var maxScale=1.3
        return maxScale-offset/10
    }

    Timer{//定时器触发歌词跟随
        id:lyricFollowTim
        interval: lyricListView.delayTime
        onTriggered: {
            lyricListView.isFollowed=true
        }
    }

    ListView{
        id:listView
        width: parent.width
        height: parent.height

        //滚动逻辑
        MouseArea{
            anchors.fill: parent
            onWheel: function(wheel){
                //开启歌词跟随计时
                lyricListView.isFollowed=false
                lyricFollowTim.restart()

                if(wheel.angleDelta.y>0&&listView.currentIndex>0){
                    listView.currentIndex-=1
                }else if(wheel.angleDelta.y<0&&listView.currentIndex<listView.count-1){
                    listView.currentIndex+=1
                }
            }
        }

        preferredHighlightBegin: parent.height/2-40//高亮区域起始y坐标
        preferredHighlightEnd: height/2
        highlightMoveDuration: 500
        highlightRangeMode: ListView.StrictlyEnforceRange
        currentIndex: 0
        model: lyricListView.lyricData
        interactive: false//禁用自带的滚动
        delegate: lyricDelegate
        spacing: 20
        clip: true
    }
    Component{
        id:lyricDelegate
        Rectangle{
            id:lyricItem
            property double maxWidth: lyricListView.width*0.6
            property bool isHovered: false
            width: children[0].width+30
            height: children[0].height+30
            radius: 12
            scale: lyricListView.offsetScale(index,listView.currentIndex)
            transformOrigin: Item.Left//向右缩放
            color: if(isHovered)return thisTheme.itemHoverColor
                        else return "#00000000"
            Behavior on color{
                ColorAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale{

                NumberAnimation {
                    property: "scale"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Column {
                property double childMaxWidth: children[0].contentWidth
                spacing: 15
                width: childMaxWidth>lyricItem.maxWidth?lyricItem.maxWidth:childMaxWidth
                height: children[0].height+children[1].height+spacing
                anchors.centerIn: parent
                Text {
                    width: parent.width
                    height: text===""?0:contentHeight
                    wrapMode: Text.Wrap
                    font.pointSize: 15
                    font.bold: true
                    color: lyricListView.current===index?thisTheme.primaryTextColor:"#7FFFFFFF"
                    text: lyric
                    onContentWidthChanged: function (contentWidth){
                        if(contentWidth>parent.childMaxWidth){
                            parent.childMaxWidth=contentWidth
                        }/*else{
                            width=contentWidth
                        }*/
                    }
                }
                Text {
                    width: parent.width
                    height: text===""?0:contentHeight
                    font.pointSize: 15
                    font.bold: true
                    wrapMode: Text.Wrap
                    text: tlrc
                    color: lyricListView.current===index?"#FFFFFF":"#7FFFFFFF"
                    onContentWidthChanged: function (contentWidth){
                        if(contentWidth>parent.childMaxWidth){
                            parent.childMaxWidth=contentWidth
                        }
                    }
                }
            }
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    lyricListView.current=index
                    listView.currentIndex=index
                    // mediaPlayer.position=tim//点击后播放进度跳转
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
    Connections{
        target: mediaPlayer
        function onPositionChanged(pos){
            for(let i=0;i<listView.count;i++){
                if(pos>lyricData.get(i).tim){
                    if(i===listView.count-1){
                        lyricListView.current=i
                        break
                    }else if(lyricData.get(i+1).tim>pos){
                        lyricListView.current=i
                        break
                    }
                }
            }
        }
    }
}
