import QtQuick

Item {
    id:lyricListView
    width: parent.width
    height: parent.height

    property ListModel lyricData:ListModel{}
    property int current: -1

    ListView{
        id:listView
        width: parent.width
        height: parent.height

        //滚动逻辑
        MouseArea{
            anchors.fill: parent
            onWheel: function(wheel){
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
        currentIndex: -1
        interactive: false
        model: lyricListView.lyricData
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
            color: if(isHovered)return "#2F000000"
                        else return "#00000000"

            Behavior on color{
                ColorAnimation {
                    from: "#00000000"
                    to: "#2F000000"
                    duration: 400
                    easing.type: Easing.OutCubic
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
                    color: "WHITE"
                    text: /*lyric*/"122222"
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
                    text: /*tlrc*/"12334"
                    color: "WHITE"
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
                    listView.currentIndex=index
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
