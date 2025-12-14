import QtQuick
import QtQuick.Effects
import QtQuick.Controls //引入 Controls 模块以使用 ScrollView

Item {
    id: playListContent
    anchors.fill: parent // 建议让根节点填满父容器，而不是手动算高度

    property var thisTheme: p_theme.m_currentTheme
    property var headerData: [{name:"ACG"},
    {name:"电子"},
    {name:"流行"},
    {name:"欧美"},
    {name:"古风"}]
    property var boutiquePlayListData: []
    property var contentItemSourceSize: Qt.size(minContentItemWidth,minContentItemHeight)
    property double fontSize: 11
    property var loadItems: []
    property int headerCurrent: 0
    property double minContentItemWidth: 200
    property double minContentItemHeight: minContentItemWidth*1.3
    property double contentItemWidth: minContentItemWidth
    property double contentItemHeight: contentItemWidth*1.3

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
            // 注意：这里要做个非空判断，防止 crash
            if (boutiquePlayListData.length > 0) {
                headerBackground_1.source=boutiquePlayListData[0].coverImg
                headerBoutiquePlayListInfo.nameText=boutiquePlayListData[0].name
                headerBoutiquePlayListInfo.descriptionText=boutiquePlayListData[0].description
                console.log("BoutiquePlayList:"+JSON.stringify(res[0]))
            }
        }
        var playListCallBack=res=>{
            var rows=Math.ceil(res.length/content.columns)
            contentModel.clear()
            contentModel.append(res)
            // 重新计算 Grid 高度
            content.height=rows*contentItemHeight+rows*content.spacing
            console.log("playListCallBack:"+JSON.stringify(res[0]))
        }

        p_musicRes.getMusicBoutiquePlayList({cat:cat,callBack:boutiquePlayListCallBack})
        p_musicRes.getMusicPlayList({cat:cat,callBack:playListCallBack})
    }

    function setContentItemSize(){
        var w=content.width
        var columns=content.columns
        // 防止除以0或死循环，加个保险
        if (w <= 0) return;

        while(true){
            if(w>=columns*content.spacing+(columns+1)*minContentItemWidth){
                columns+=1
            }else if(columns > 1 && w<(columns-1)*content.spacing+columns*minContentItemWidth){

                columns-=1
            }else {
                break
            }
        }
        content.columns=columns
        content.rows=Math.ceil(contentModel.count/columns)
        contentItemWidth=w/columns-((columns-1)*content.spacing)/columns
        content.height=content.rows*(contentItemHeight+content.spacing)
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth // 禁止水平滚动
        clip: true // 裁剪超出边界的内容

        //添加一个主 Column 包裹 Header 和 Content
        Column {
            id: mainColumn
            width: scrollView.availableWidth // 宽度跟随 ScrollView
            spacing: 20

            // 底部留白，防止内容贴底
            bottomPadding: 80

            // Header 部分
            Column {
                id: header
                width: parent.width*0.9
                // height:headerBackground.height+headerPlayListSelectBar.height+spacing
                topPadding: 30

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
                    }
                    RoundImage{
                        id:headerBackground_2
                        z:headerBackground_1.z+1
                        imgWidth: parent.width
                        imgHeight: parent.height
                        anchors.fill: parent
                        radius:12
                        source:headerBackground_1.source
                    }
                    MultiEffect {
                        anchors.fill: parent
                        source: headerBackground_1
                        blurEnabled: true
                        blurMax: 70
                        blur: 0.25
                        blurMultiplier: 1.5
                    }
                    MultiEffect {
                        anchors.fill: parent
                        z:headerBackground_2.z+1
                        source: headerBackground_2
                        blurEnabled: true
                        blurMax: 70
                        blur: 0.5
                        blurMultiplier: 2.0
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
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                color: "WHITE"
                                text: headerBoutiquePlayListInfo.nameText
                            }
                            Text {
                                width: parent.width
                                // 防止计算出负数高度
                                height: Math.max(0, parent.height-parent.children[0].height)
                                font.pointSize: playListContent.fontSize-2
                                wrapMode: Text.Wrap
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
                        border.color: thisTheme.dividerColor
                        Text {
                            font.pointSize: playListContent.fontSize
                            anchors.centerIn: parent
                            color: thisTheme.primaryTextColor
                            text: "推荐歌单"
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
                                          return thisTheme.itemSelectedColor
                                      else return "#00000000"
                                Text {
                                    font.pointSize: playListContent.fontSize-1
                                    font.bold: headerCurrent===index||parent.isHovered
                                    anchors.centerIn: parent
                                    color: if(headerCurrent===index)
                                               return thisTheme.primaryTextColor
                                           else return thisTheme.secondaryTextColor
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

            Rectangle{
                id:line
                width: parent.width
                height: 5
                color: thisTheme.dividerColor
            }

            // Grid Content 部分
            Grid {
                id: content
                width: parent.width*0.9
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                columns: 3
                onWidthChanged: {
                    if(width>0){
                        setContentItemSize()
                    }
                }

                Repeater{
                    model: ListModel{
                        id:contentModel
                    }

                    delegate: PlayListLable{
                        width: contentItemWidth
                        height: contentItemHeight
                        button.source: "qrc:/pause"
                        button.color:thisTheme.itemSelectedColor
                        button.hoveredColor: thisTheme.itemHoverColor
                        button.iconColor: "WHITE"
                        normalColor: thisTheme.alternateRowColor
                        hoveredColor: thisTheme.itemHoverColor
                        fontColor: thisTheme.primaryTextColor

                        imgSource: coverImg+"?param="+200+"y"+200
                        text: name
                        onClicked: {
                            let lb=leftBar
                            let rc=rightContent
                            let playListInfo={id:id,name:name,description:description,coverImg:coverImg}
                            let func=()=>{
                                lb.thisBtnText=""
                                rc.thisQml="PlayListDetail.qml"
                                rc.loadItem.playListInfo=playListInfo
                            }
                            func()
                            rightContent.pushStep({name:name,callBack:func})
                            console.log("标签被点击")
                        }
                        onBtnClicked: {
                            console.log("按钮被点击")
                        }
                    }
                }
            }
        }
    }
}
