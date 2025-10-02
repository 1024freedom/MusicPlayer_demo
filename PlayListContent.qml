import QtQuick
import QtQuick.Effects
Item {
    id:playListContent
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property var headerData: [{name:"ACG"},
    {name:"电子"},
    {name:"流行"},
    {name:"欧美"},
    {name:"古风"}]
    property var boutiquePlayListData: []
    property var contentItemSourceSize: Qt.size()
    property double fontSize: 11
    property var loadItems: []
    property int headerCurrent: 0
    property double minContentItemWidth: 240
    property double minContentItemHeight: minContentItemWidth*1.3
    property double contentItemWidth: minContentItemWidth
    property double contentItemHeight: minContentItemHeight

    width: parent.width
    height: header.height+content.height+80

    Component.onCompleted: {
        setContentModel(headerData[headerCurrent].name)
    }

    onHeaderCurrentChanged: {
        setContentModel(headerData[headerCurrent].name)
    }

    function setContentModel(cat){
        content.height=0
        var boutiquePlayListCallBack=res=>{
            boutiquePlayListData=res.slice(0,res.length)
            headerBackground_1.source=boutiquePlayListData[0].coverImg
            headerBoutiquePlayListInfo.nameText=boutiquePlayListData[0].name
            headerBoutiquePlayListInfo.descriptionText=boutiquePlayListData[0].description
            console.log("BoutiquePlayList:"+JSON.stringify(res[0]))
        }
        var playListCallBack=res=>{
            var rows=Math.ceil(res.length/content.columns)
            contentModel.clear()
            contentModel.append(res)
            content.height=rows*contentItemHeight+rows*content.spacing
            console.log("playListCallBack:"+JSON.stringify(res[0]))
        }

        p_musicRes.getMusicBoutiquePlayList({cat:cat,callBack:boutiquePlayListCallBack})
        p_musicRes.getMusicPlayList({cat:cat,callBack:playListCallBack})
    }

    function setContentItemSize(){

    }

    Column {
        id: header
        width: parent.width*0.9
        height:headerBackground.height+headerPlayListSelectBar.height+spacing
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20
        Item {
            id:headerBackground
            width: parent.width
            height: 160
            RoundImage{
                id:headerBackground_1
                anchors.fill: parent
                imgWidth: parent.width
                imgHeight: parent.height
                radius:12
                source:"qrc:/yy"
                sourceSize: Qt.size(50,50)
            }
            RoundImage{
                id:headerBackground_2
                z:headerBackground_1.z+1
                imgWidth: parent.width
                imgHeight: parent.height
                anchors.fill: parent
                radius:12
                source:headerBackground_1.source
                sourceSize: headerBackground_1.sourceSize
            }
            // 边缘淡发光效果
            MultiEffect {
               anchors.fill: parent
               source: headerBackground_1
               blurEnabled: true
               blurMax: 70
               blur: 0.25  // 0.0-1.0 范围
               blurMultiplier: 1.5
            }

           // 模糊背景效果
            MultiEffect {
               anchors.fill: parent
               z:headerBackground_2.z+1
               source: headerBackground_2
               blurEnabled: true
               blurMax: 70
               blur: 0.5  // 更强的模糊效果
               blurMultiplier: 2.0
               // 颜色叠加效果设置
                // colorization: 0.5  // 颜色化强度 0.0-1.0
                // colorizationColor: "#4F000000"  // 半透明黑色
            }

            Item {
                id: headerBoutiquePlayListInfo
                property string nameText: ""
                property string descriptionText: ''
                z:headerBackground_2.z+1
                width: parent.width-30
                height: parent.height-30
                anchors.centerIn: parent
                RoundImage{
                    id:boutiquePlayListCoverImg
                    width: parent.height
                    height: width
                    imgHeight: 130
                    imgWidth: 130
                    radius: 10
                    source: headerBackground_2.source
                    sourceSize: Qt.size(width,height)
                }
                Column{
                    width: parent.width-boutiquePlayListCoverImg.width
                    height: parent.height
                    anchors.left: boutiquePlayListCoverImg.right
                    anchors.leftMargin: 15
                    anchors.verticalCenter: boutiquePlayListCoverImg.verticalCenter
                    spacing: 15
                    Text {
                        width: parent.width
                        height: contentHeight
                        font.pointSize: playListContent.fontSize
                        wrapMode: Text.Wrap//换行规则保证单词完整
                        elide: Text.ElideRight
                        color: "WHITE"
                        text: headerBoutiquePlayListInfo.nameText
                    }
                    Text {
                        width: parent.width
                        height: if(parent.height-parent.children[0].height-contentHeight<0)
                                    return contentHeight
                                else return parent.height-parent.children[0].height
                        font.pointSize: playListContent.fontSize-2
                        wrapMode: Text.Wrap//换行规则保证单词完整
                        elide: Text.ElideRight
                        color: "WHITE"
                        text: headerBoutiquePlayListInfo.descriptionText
                    }
                }
            }
        }
        Item {
            id: headerPlayListSelectBar
            width: parent.width
            height: children[0].height
            Rectangle{
                width: children[0].contentWidth+30
                height: children[0].contentHeight+15
                radius: width/2
                color: "#00000000"
                border.color: thisTheme.fontColor
                Text {
                    font.pointSize: playListContent.fontSize
                    anchors.centerIn: parent
                    color: thisTheme.fontColor
                    text: "ACG"
                }
            }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                Repeater{
                    id:headerRepeater
                    model: playListContent.headerData.length
                    delegate: Rectangle{
                        property bool isHovered: false
                        width: children[0].contentWidth+25
                        height: children[0].contentHeight+15
                        radius: width/2
                        color: if(headerCurrent===index)
                                   return thisTheme.subBackgroundColor
                                else return "#00000000"
                        Text {
                            font.pointSize: playListContent.fontSize-1
                            font.bold: headerCurrent===index||parent.isHovered
                            anchors.centerIn: parent
                            color: if(headerCurrent===index)
                                       return thisTheme.subBackgroundColor+"F"
                                    else return thisTheme.fontColor
                            text: playListContent.headerData[index].name
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                headerCurrent=index
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

    }
    Grid {
        id: content
        width: parent.width*0.9
        height: 1000
        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20
        columns: 3
        Repeater{
            model: ListModel{
                id:contentModel
            }

            delegate: PlayListLable{
                width: contentItemWidth
                height: contentItemHeight
                button.source: "qrc:/pause"
                button.color:thisTheme.subBackgroundColor
                button.hoveredColor: thisTheme.subBackgroundColor+"F"
                button.iconColor: "WHITE"
                normalColor: "WHITE"
                hoveredColor: thisTheme.subBackgroundColor
                fontColor: thisTheme.fontColor
                imgSourceSize: Qt.size(width,height)
                imgSource: coverImg+"?param="+200+"y"+200
                text: name
                onClicked: {
                    console.log("标签被点击")
                }
                onBtnClicked: {
                    console.log("按钮被点击")
                }
            }
        }
    }

}
