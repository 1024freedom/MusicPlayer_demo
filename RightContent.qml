import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:rightContent
    property string thisQml: ""
    property var thisTheme: p_theme.defaultTheme[p_theme.current]

    property var stepPage: []//页面前进/回退相关
    property int stepCurrent: -1
    property int stepPageCount: 0

    property alias loadItem: rightContentLoader.item
    color:  thisTheme.subColor

    function preStep(){
        if(stepCurrent<=0)return
        stepCurrent-=1
        stepPage[stepCurrent].callBack()
        console.log("执行命令"+stepPage[stepCurrent].name)
    }
    function nextStep(){
        if(stepCurrent>=stepPageCount-1)return
        stepCurrent+=1
        stepPage[stepCurrent].callBack()
        console.log("执行命令"+stepPage[stepCurrent].name)
    }
    function pushStep(obj){
        let infp={name:"",callBack:(()=>{})}
        stepPage.push(obj)
        stepCurrent+=1
        stepPageCount=stepPage.length
    }

    Loader{
        id:rightContentLoader
        source: rightContent.thisQml
        onLoaded: {
            item.parent=parent
        }
    }
}
