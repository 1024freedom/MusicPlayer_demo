import QtQuick

Flickable {
    id:findMusicFlickable
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property var headerData: [{headerText:"歌单",qml:""},
        {headerText:"新歌速递",qml:""},
        {headerText:"个性推荐",qml:""},
        {headerText:"专属定制",qml:""}]
    property double fontSize: 11
    anchors.fill: parent
    Rectangle{
        id:findMusicHeader
        property double topBottomPadding: 25
        property double leftRightPadding: 25
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        anchors.topMargin: 25
        radius:width/2
        color: thisTheme.subBackgroundColor
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
                width: children[0].contentWidth+findMusicHeader.leftRightPadding
                height: children[0].contentHeight+findMusicHeader.topBottomPadding
                Text {
                    anchors.centerIn: parent
                    font.pointSize: findMusicFlickable.fontSize
                    text: headerText
                    color: thisTheme.fontColor
                }
            }
        }
    }
}
