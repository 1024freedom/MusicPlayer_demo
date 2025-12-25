import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:rightContent
    property string thisQml: ""
    property var thisTheme: p_theme.m_currentTheme
    property string searchKeyword: ""

    property var stepPage: []//页面前进/回退相关
    property int stepCurrent: -1
    property int stepPageCount: 0

    property alias loadItem: rightContentLoader.item
    color:  thisTheme.contentBackgroundColor
    //-----防止回退时触发新的push------
    property bool isHistoryNavigating: false

    function preStep(){
        if(stepCurrent<=0)return
        isHistoryNavigating=true
        stepCurrent-=1
        stepPage[stepCurrent].callBack()
        console.log("执行命令"+stepPage[stepCurrent].name)
        isHistoryNavigating=false
    }
    function nextStep(){
        if(stepCurrent>=stepPageCount-1)return
        isHistoryNavigating=true
        stepCurrent+=1
        stepPage[stepCurrent].callBack()
        console.log("执行命令"+stepPage[stepCurrent].name)
        isHistoryNavigating=false
    }
    function pushStep(obj){
        if(isHistoryNavigating)return
        //如果当前不在队尾，产生新操作时，截断后面的历史
        if(stepCurrent<stepPageCount-1){
            stepPage=stepPage.slice(0,stepCurrent+1)
        }

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
        Binding{
            target:rightContentLoader.item//当前加载的页面
            //------加载搜索结果页面时把搜索关键词传进去------
            property: "searchKeyword"
            value:rightContent.searchKeyword
            // 保护措施：只有当页面加载了且页面里确实有这个属性时才生效
            when: rightContentLoader.status === Loader.Ready &&
                  rightContentLoader.item &&
                  rightContentLoader.item.hasOwnProperty("searchKeyword")
        }
    }
}
