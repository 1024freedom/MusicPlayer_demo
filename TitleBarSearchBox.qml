import QtQuick 2.15
import QtQuick.Controls

Rectangle{
    id:titleBarSearchBox
    anchors.verticalCenter: parent.verticalCenter
    width: 240
    height: searchTextField.height+10
    radius: width/2
    border.width: 4
    border.color: if(searchTextField.focus)return thisTheme.dividerColor
                        else return "#00000000"
    color: thisTheme.contentBackgroundColor
    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }
    }
    TextField{//输入框
        id:searchTextField

        width: parent.width-40
        height: contentHeight+5
        focus: searchTextField.popup.visible
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pointSize: 10
        color: thisTheme.primaryTextColor
        selectByMouse: true//允许鼠标选择文本
        background: Rectangle{
            color: "#00000000"
            border.width: 0
        }
        //----弹出层-----
        property Popup popup:Popup{
            id:suggestionPopup
            width: parent.width
            height: width
            topMargin: 60
            closePolicy: Popup.CloseOnPressOutsideParent
            background:Rectangle{
                radius: 4
                color: thisTheme.contentBackgroundColor
                border.color: thisTheme.dividerColor
                border.width: 1
            }

            //实时显示搜索建议
            contentItem: ListView{
                id:suggestionList
                width: parent.width
                implicitHeight:contentHeight>300?300:contentHeight
                clip:true
                model: ListModel{id:suggestionModel}

                //“搜索建议”标题头
                header:Item {
                    width: parent.width
                    height: 30
                    visible: suggestionModel.count>0
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        text: "搜索建议"
                        color: thisTheme.disabledTextColor
                        font.pixelSize: 12
                    }
                }


                delegate: ItemDelegate{
                    width: ListView.view.width
                    height: 30
                    hoverEnabled: true

                    background: Rectangle{
                        color: (parent.highlighted || parent.hovered) ?
                                       thisTheme.itemSelectedColor : "transparent"
                        Behavior on color{

                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                    contentItem: Text {
                        text: model.text
                        color: thisTheme.primaryTextColor
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        searchTextField.text=model.text
                        suggestionPopup.close()
                        titleBarSearchBox.showSearchResultPage()//触发搜索展示结果
                    }
                }
            }
        }
        onTextChanged: {
            var currentText=searchTextField.text
            if(currentText.length>0&&searchTextField.focus){
                titleBarSearchBox.updatePopupContent(currentText)
                suggestionPopup.open()
            }else{
                suggestionPopup.close()
            }
        }

        onPressed: {
            suggestionPopup.open()
        }
        Keys.onReturnPressed: function(){
            if(text.length>0){
                suggestionPopup.close()
                titleBarSearchBox.showSearchResultPage();
            }

        }
    }
    ToolTipButtom{
        height: parent.height
        width: height
        anchors.right: parent.right
        source:"qrc:/search"
        hintText: "搜索"
        hoveredColor: thisTheme.itemSelectedColor
        color: "#00000000"
        onClicked: {
            parent.showSearchResultPage();
        }
    }

    function showSearchResultPage(){
        searchTextField.focus=false
        titleBar.thisQml="PageSearchResult.qml"
        titleBar.searchKeyword=searchTextField.text
    }
    function updatePopupContent(searchText){
        p_musicSearch.searchSuggest({//result是提示词组成的字符串数组
            "keywords":searchText,
            "callBack":function(result){
                suggestionModel.clear()
                if (result && result.length > 0) {
                    for (var i = 0; i < result.length; i++) {
                        suggestionModel.append({ "text": result[i] })
                    }
                    // 数据填充完毕后再打开 Popup
                    suggestionPopup.open()
                } else {
                    suggestionPopup.close()
                }
            }
        })

    }
}
