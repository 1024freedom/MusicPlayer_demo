import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:leftBar
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property var leftBarData:
        [{headerText:"发现音乐",
            btnData:[
                {btnText:"乐库",btnIcon:"qrc:/music",qml:"",isActive:true},
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

    property var thisData: filterLeftBarData(leftBarData)
    property string thisQml: ""
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
            spacing: 10
            Repeater{
                id:leftBarRepeater
                model: leftBar.thisData.length
                delegate: repeaterDelegate
            }
        }
        Component{
            id:repeaterDelegate
            ListView{
                id:listView
                width: leftBarFlickable.width
                height: 80
                interactive: false//禁止拖拽
                model: ListModel{}
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
                width: leftBarFlickable.width-15
                height: leftBar.btnHeight
                color: if(isHovered)return leftBar.thisTheme.subBackgroundColor
                    else return "#00000000"
                Row{
                    Image {
                        source: btnIcon
                        sourceSize: Qt.size(32,32)
                        width: 20
                        height: width
                    }
                    Text {
                        font.pointSize: leftBar.fontSize
                        color: leftBar.thisTheme.fontColor
                        text: qsTr("text")
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
