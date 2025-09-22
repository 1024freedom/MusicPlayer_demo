import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:leftBar
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property var leftBarData:
        [{headerText:"发现音乐",
            btnData:[
                {btnText:"乐库",btnIcon:"qrc:/music",qml:"PageFindMusic.qml",isActive:true},
                {btnText:"歌单",btnIcon:"qrc:/list",qml:"",isActive:true}
                ],
            isActive:true
            },
        {headerText:"我的音乐",
            btnData:[
                {btnText:"我的收藏",btnIcon:"qrc:/like",qml:"",isActive:true},
                {btnText:"最近播放",btnIcon:"qrc:/recent",qml:"",isActive:true},
                {btnText:"本地音乐",btnIcon:"qrc:/local",qml:"",isActive:true},
                {btnText:"下载",btnIcon:"qrc:/download",qml:"",isActive:true}
                ],
            isActive:true
            }
        ]
    width: 180
    height: parent.height
    color: thisTheme.backgroundColor

    property var thisData: filterLeftBarData(leftBarData)
    property string thisQml: "PageFindMusic.qml"
    property string thisBtnText: "发现音乐"
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
                    color: leftBar.thisTheme.fontColor
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
                color: if(isHovered)return leftBar.thisTheme.subBackgroundColor
                    else return "#00000000"

                Rectangle{
                    width: parent.isThisBtn?parent.width:0
                    height: parent.height
                    radius: parent.radius
                    color: leftBar.thisTheme.clickBackgroundColor
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
                    Image {
                        source: btnIcon
                        sourceSize: Qt.size(32,32)
                        width: 20
                        height: width
                    }
                    Text {
                        font.bold: isThisBtn?true:false
                        scale: isThisBtn?1.1:1
                        font.pointSize: leftBar.fontSize
                        color: leftBar.thisTheme.fontColor
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
                        leftBar.thisBtnText=btnText
                        leftBar.thisQml=qml
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
