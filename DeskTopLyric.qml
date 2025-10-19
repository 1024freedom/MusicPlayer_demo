import QtQuick
import sz.window
DesktopLyric {//DesktopLyric是c++文件的名称
    id:desktopLyric
    property int fontSize: 15
    property var mediaPlayer: null
    property ListModel lyricData: ListModel{}
    property int current: -1

    width: 600
    height: 150

    onCurrentChanged: {
        if(current<=-1)return
        lyricColumn.lyricText=lyricData.get(current).lyric
        lyricColumn.tlyricText=lyricData.get(current).tlrc
    }

    Connections{
        enabled: mediaPlayer!=null
        target: mediaPlayer
        function onPositionChanged(pos){
            let index=-1
            for(let i=0;i<lyricData.count;i++){
                if(pos>lyricData.get(i).tim){
                    if(i===lyricData.count-1){
                        index=i
                        break
                    }else if(lyricData.get(i+1).tim>pos){
                        index=i
                        break
                    }
                }
            }
            current=index
        }
    }

    Rectangle{
        width: parent.width
        height: parent.height
        color: "#AF000000"
        Column{
            width: parent.width-60
            height: parent.height-40
            anchors.centerIn: parent
            clip: true
            Row{
                id:toolBar
                width: 35
                height: width
            }

            Column {
                id:lyricColumn
                property double childMaxWidth: children[0].contentWidth
                property string lyricText: ""
                property string tlyricText: ""
                spacing: 15
                width: childMaxWidth>lyricColumn.maxWidth?lyricColumn.maxWidth:childMaxWidth
                height: children[0].height+children[1].height+spacing
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    width: parent.width
                    height: text===""?0:contentHeight
                    wrapMode: Text.Wrap
                    font.pointSize:desktopLyric.fontSize
                    font.bold: true
                    color: "#FFFFFF"
                    text: lyricColumn.lyricText
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
                    font.pointSize: desktopLyric.fontSize
                    font.bold: true
                    wrapMode: Text.Wrap
                    text: lyricColumn.tlyricText
                    color: "#FFFFFF"
                    onContentWidthChanged: function (contentWidth){
                        if(contentWidth>parent.childMaxWidth){
                            parent.childMaxWidth=contentWidth
                        }
                    }
                }
            }
        }


    }
}
