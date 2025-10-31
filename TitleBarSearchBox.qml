import QtQuick 2.15
import QtQuick.Controls

Rectangle{
    id:titleBarSearchBox
    anchors.verticalCenter: parent.verticalCenter
    width: 240
    height: searchTextField.height+10
    radius: width/2
    border.width: 2
    border.color: if(searchTextField.focus)return thisTheme.subColor
                        else return "#00000000"
    color: thisTheme.subBackgroundColor
    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }
    }
    TextField{//输入框
        id:searchTextField
        property Popup popup:Popup{
            width: parent.width
            height: width
            topMargin: 60
            closePolicy: Popup.CloseOnPressOutsideParent
            //实时显示搜索建议
            contentItem: ListView{
                id:suggestionList
                model: ListModel{id:suggestionModel}
                delegate: ItemDelegate{
                    width: parent.width
                    text: model.text
                    onClicked: {

                    }
                }
            }
        }
        onTextChanged: {
            var currentText=searchTextField.text
            if(currentText.length>0){
                titleBarSearchBox.updatePopupContent(currentText)
                popup.open()
            }
        }

        width: parent.width-40
        height: contentHeight+5
        focus: searchTextField.popup.visible
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pointSize: 10
        color: thisTheme.fontColor
        background: Rectangle{
            color: "#00000000"
            border.width: 0
        }
        onPressed: {
            searchTextField.popup.open()
        }
        Keys.onReturnPressed: function(){
            if(text.length>0){
                titleBarSearchBox.showSearchResultPage();
            }

        }
    }
    ToolTipButtom{
        height: parent.height
        width: height
        anchors.right: parent.right
        source:"qrc:/search"
        color: if(isHovered)return thisTheme.subColor
                else return "#00000000"
        onClicked: {
            parent.showSearchResultPage();
        }
    }

    function showSearchResultPage(){
        searchTextField.focus=false
        TitleBar.thisQml="PageSearchResult.qml"
    }
    function updatePopupContent(searchText){
        suggestionModel.clear()

    }
}
