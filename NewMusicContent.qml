import QtQuick

Item {
    id:newMusicContent
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property var headerData: [{name:"全部",type:"0"},
    {name:"华语",type:"7"},
    {name:"欧美",type:"96"},
    {name:"日本",type:"8"},
    {name:"韩国",type:"16"},]
    property double fontSize: 11
    property var loadItems: []
    property int startY: parent.y
    property int headerCurrent: 0
    property int current: -1
    property int contentItemHeight: 80
    width: parent.width
    height: header.height+content.height+80

    onHeaderCurrentChanged: {
        setContentModel()
    }

    Component.onCompleted: {
        setContentModel()
        // var callBack=res=>{
        //     console.log(JSON.stringify(res[0]))
        //     content.height=res.length*80+20
        //     contentModel.append(res)
        // }
        // p_musicRes.getNewMusic({type:headerData[headerCurrent].type,callBack})
    }

    function setContentModel(){
        content.height=0
        contentModel.clear()
        var callBack=res=>{
            console.log(JSON.stringify(res[0]))
            content.height=res.length*80+20
            contentModel.append(res)
        }
        p_musicRes.getNewMusic({type:headerData[headerCurrent].type,callBack})
    }
    function setContentItemVisible(){

    }

    Row {
        id: header
        spacing: 10
        width: parent.width*0.9
        height: 20
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater{
            model: ListModel{}
            delegate: headerDelegate
            Component.onCompleted: {
                model.append(newMusicContent.headerData)
            }
        }
        Component{
            id:headerDelegate
            Text {
                property bool isHovered: false
                font.bold: isHovered||newMusicContent.headerCurrent===index
                font.pointSize: newMusicContent.fontSize
                text: name
                color: "#C3C3C3"
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        newMusicContent.headerCurrent=index
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
    Rectangle{
        id:content
        width: parent.width*0.9
        height: 0
        anchors.top: header.bottom
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 10
        /*Column*/Item{
            // topPadding: 10
            width: parent.width-20

            anchors.horizontalCenter: parent.horizontalCenter
            Repeater{
                model: ListModel{
                    id:contentModel
                }
                delegate: contentDelegate
            }
        }
        Component{
            id:contentDelegate
            Rectangle{
                property bool isHovered: false
                width: content.width-20
                height: newMusicContent.contentItemHeight
                radius: 10

                visible:false
                y:index*newMusicContent.contentItemHeight+10

                anchors.horizontalCenter: parent.horizontalCenter
                color: if(newMusicContent.current===index)
                           return thisTheme.subBackgroundColor
                        else if(isHovered) return thisTheme.subBackgroundColor
                        else return "#00000000"
                Row{
                    width: parent.width-20
                    height: parent.height-20
                    spacing: 10
                    anchors.centerIn: parent
                    Text {
                        width: parent.width*0.1-40
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.weight: 2
                        font.pointSize: newMusicContent.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: index+1
                    }
                    RoundImage{
                        width: 60
                        height: width
                        source:coverImg+"?param="+width+"y"+height
                        //告诉图片服务器 “需要返回宽为 width、高为 height 的图片”，
                        //服务器会根据这些参数对原始图片进行缩放、裁剪等处理后再返回。减少内存占用
                    }
                    Text {
                        width: parent.width*0.3
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignLeft
                        font.weight: 2
                        font.pointSize: newMusicContent.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: name
                    }
                    Text {
                        width: parent.width*0.2
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignLeft
                        font.weight: 2
                        font.pointSize: newMusicContent.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: artists
                    }
                    Text {
                        width: parent.width*0.2
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignLeft
                        font.weight: 2
                        font.pointSize: newMusicContent.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: album
                    }
                    Text {
                        width: parent.width*0.2-parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignLeft
                        font.weight: 2
                        font.pointSize: newMusicContent.fontSize
                        elide: Text.ElideRight
                        color: thisTheme.fontColor
                        text: allTime
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {

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
}
