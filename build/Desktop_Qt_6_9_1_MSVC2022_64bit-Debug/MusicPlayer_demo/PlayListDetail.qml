import QtQuick

ListView {
    id: playListDetail
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property int fontSize: 11
    width: parent.width
    height: parent.height

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
                    source: "qrc:/yy"
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
                        text: "歌单名"
                    }
                    Text {
                        width: parent.width
                        font.pointSize: playListDetail.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: "歌单信息"
                    }
                }
            }
        }
    }
    model: 10
    delegate: Rectangle{
        width: playListDetail.width-80
        height: 80
        onParentChanged: {
            if(parent!=null){
                anchors.horizontalCenter=parent.horizontalCenter
            }
        }
    }

}
