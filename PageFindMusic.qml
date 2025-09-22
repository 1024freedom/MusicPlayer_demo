import QtQuick

Flickable {
    id:findMusicFlickable
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property var headerData: [{headerText:"歌单",qml:"PlayListContent.qml"},
        {headerText:"新歌速递",qml:"NewMusicContent.qml"},
        {headerText:"个性推荐",qml:""},
        {headerText:"专属定制",qml:""}]
    property double fontSize: 11
    anchors.fill: parent
    Rectangle{
        id:findMusicHeader
        property int current: 0
        property double topBottomPadding: 25
        property double leftRightPadding: 35
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 25
        radius:width/2
        color: thisTheme.backgroundColor
        Row{
            Repeater{
                model: ListModel{}
                delegate: findMusicHeaderDelegate
                Component.onCompleted: {
                    model.append(findMusicFlickable.headerData)
                }
                onCountChanged: {
                    var w=0
                    var h=0
                    for(var i=0;i<count;i++){
                        w+=itemAt(i).width
                        if(h<itemAt(i).height){
                            h=itemAt(i).height
                        }
                        findMusicHeader.width=w
                        findMusicHeader.height=h
                    }
                }
            }
        }
        Component{
            id:findMusicHeaderDelegate
            Rectangle{
                property bool isHovered: false
                width: children[0].contentWidth+findMusicHeader.leftRightPadding
                height: children[0].contentHeight+findMusicHeader.topBottomPadding
                radius: width/2
                color: if(findMusicHeader.current===index)
                           return thisTheme.subBackgroundColor
                        else if(isHovered) return "PINK"
                        else return thisTheme.backgroundColor
                Text {
                    anchors.centerIn: parent
                    font.pointSize: findMusicFlickable.fontSize
                    font.bold: findMusicHeader.current===index
                    text: headerText
                    color: thisTheme.fontColor
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        findMusicHeader.current=index
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
    Item {
        id:findMusicContent
        width: parent.width*0.85
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: findMusicHeader.bottom
        anchors.topMargin: 25
        Loader{
            source: findMusicFlickable.headerData[findMusicHeader.current].qml
            onStatusChanged: {
                if(status===Loader.Ready){
                    item.parent=findMusicContent

                }
            }
        }
    }
}
