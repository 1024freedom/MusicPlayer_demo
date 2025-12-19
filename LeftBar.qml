import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:leftBar
    property var thisTheme: p_theme.m_currentTheme
    property var leftBarData:
        [{headerText:"发现音乐",
            btnData:[
                {btnText:"新歌速递",btnIcon:"qrc:/music",qml:"PageFindMusic.qml",isActive:true},
                {btnText:"歌单",btnIcon:"qrc:/list",qml:"PlayListContent.qml",isActive:true}
                ],
            isActive:true
            },
        {headerText:"我的音乐",
            btnData:[
                {btnText:"我的收藏",btnIcon:"qrc:/like",qml:"PageFavoriteMusicDetail.qml",isActive:true},
                {btnText:"最近播放",btnIcon:"qrc:/recent",qml:"PagePlayHistory.qml",isActive:true},
                {btnText:"本地音乐",btnIcon:"qrc:/local",qml:"",isActive:true},
                {btnText:"下载",btnIcon:"qrc:/download",qml:"PageDownload.qml",isActive:true}
                ],
            isActive:true
            }
        ]
    width: 180
    height: parent.height
    color: p_theme.m_currentTheme.windowBackgroundColor

    property var thisData: filterLeftBarData(leftBarData)
    property string thisQml: "PageFindMusic.qml"
    property string thisBtnText: "乐库"
    property int count: thisData.length
    property int btnHeight: 40
    property int fontSize: 11

    function filterLeftBarData(leftBarData){//筛选需要显示的数据
        let filteredData=leftBarData.map(item=>{//遍历
            if(item.isActive){
                let filteredBtnData=item.btnData.filter(btn=>btn.isActive);
                return{headerText:item.headerText,btnData:filteredBtnData};
            }
            return null;
        }).filter(item=>item!==null);
        return filteredData
    }

    Flickable{//可滚动
        id:leftBarFlickable
        anchors.fill: parent
        Column{
            topPadding: 10
            spacing: 15
            Repeater{
                id:leftBarRepeater
                model: leftBar.count
                delegate: repeaterDelegate
            }
        }
        Component{
            id:repeaterDelegate
            ListView{
                id:listView
                width: leftBarFlickable.width
                height: leftBar.btnHeight*count+40
                interactive: false//禁止拖拽
                spacing:7
                model: ListModel{}
                header: Text {
                    font.pointSize: leftBar.fontSize-2
                    color: leftBar.thisTheme.primaryTextColor
                    text: leftBar.thisData[index].headerText
                    padding: 5
                }
                delegate: listViewDelegate
                Component.onCompleted: {
                    model.append(leftBar.thisData[index].btnData)
                }
            }
        }
        Component{
            id:listViewDelegate
            Rectangle{
                property bool isHovered: false
                property bool isThisBtn: leftBar.thisBtnText===btnText//当前按钮是否被选中
                width: leftBarFlickable.width-15
                height: leftBar.btnHeight
                radius: 50
                color: if(isHovered)return leftBar.thisTheme.itemHoverColor
                    else return "#00000000"

                onParentChanged: {
                    if(parent!=null){
                        anchors.horizontalCenter=parent.horizontalCenter
                    }
                }

                Rectangle{
                    width: parent.isThisBtn?parent.width:0
                    height: parent.height
                    radius: parent.radius
                    color: leftBar.thisTheme.itemSelectedColor
                    Behavior on width {
                        NumberAnimation{
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }//平滑的动画过渡
                }

                Row{
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter
                    ThemeImage{
                        width: 20
                        height: width
                        source: btnIcon
                        color: thisTheme.accentColor
                    }

                    Text {
                        font.bold: isThisBtn?true:false
                        scale: isThisBtn?1.1:1
                        font.pointSize: leftBar.fontSize
                        color: leftBar.thisTheme.primaryTextColor
                        text: btnText
                        Behavior on scale {
                            NumberAnimation{
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        let func=()=>{
                            leftBar.thisQml=qml
                            leftBar.thisBtnText=btnText
                        }
                        func()
                        rightContent.pushStep({name:btnText,callBack:func})
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
