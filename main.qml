import QtQuick
import sz.window
import QtQuick.Layouts

FramelessWindow {
    id:window
    width: 1010
    height: 710
    minimumWidth:1010
    minimumHeight: 710
    visible: true
    title: qsTr("Muisc of Freedom")

    MusicResource{
        id:p_musicRes
    }

    MusicPlayer{
        id:p_musicPlayer
        source: p_musicRes.thisPlayMusicInfo.url
    }

    FavoriteManager{
        id:p_favoriteManager
        // savePath: "userInfo/favoriteMusic.json"
    }
    ImageColor{
        id:p_imageColor
    }
    ThemeManager{
        id:p_theme
    }
    PlayHistoryManager{
        id:p_history
    }
    MusicDownload{
        id:p_musicDownloader
    }
    LocalMusicManager{
        id:p_localmusicManager
    }
    MusicSearch{
        id:p_musicSearch
    }

    Column{
        id:mainPage
        anchors.fill: parent

        TitleBar{
            id:titleBar
            width:parent.width
            height: 80
            color:thisTheme.windowBackgroundColor
        }

        Rectangle{
            id:content
            width: parent.width
            height: window.height-titleBar.height-bottomBar.height
            Row{
                width: parent.width
                height: parent.height
                LeftBar{
                    id:leftBar
                    width: 180
                    height: parent.height
                }
                RightContent{
                    id:rightContent
                    width: parent.width-leftBar.width
                    height: parent.height
                    thisQml: leftBar.thisQml
                    Binding on thisQml{
                        when:leftBar.thisBtnText!==""
                        value:leftBar.thisQml
                    }
                    Binding on thisQml {
                        when:titleBar.thisQml!==""
                        value:titleBar.thisQml
                    }

                    searchKeyword:titleBar.searchKeyword

                    onThisQmlChanged: {
                        if(rightContent.isHistoryNavigating)return
                        if(thisQml==="")return
                    }

                    function addCurrentPageToHistory(){
                        var qml=""
                        var btnText=""
                        var isTitle=false
                        if(titleBar.thisQml!==""){
                            qml=titleBar.thisQml
                            btnText=""
                            isTitle=true
                        }else{
                            qml=leftBar.thisQml
                            btnText=leftBar.thisBtnText
                            isTitle=false
                        }
                        let func_title=()=>{
                            leftBar.thisBtnText=""
                            titleBar.thisQml=qml
                        }
                        let func_left=()=>{
                            titleBar.thisQml=""
                            leftBar.thisQml=qml
                            leftBar.thisBtnText=btnText
                        }

                        rightContent.pushStep({name:isTitle?"": btnText,callBack:isTitle?func_title:func_left})
                    }

                    Component.onCompleted: {
                        addCurrentPageToHistory()
                    }
                    //----监听titlebar搜索动作-----
                    Connections{
                        target: titleBar
                        function onSearchKeywordChanged(){
                            leftBar.thisBtnText=""
                            titleBar.thisQml ="PageSearchResult.qml"
                        }
                    }
                }
            }
        }
        BottomBar{
            id:bottomBar
            width: parent.width
            height: 80
        }
    }

    Loader{//懒加载
        id:musicLyricPage
        property bool isShow: false
        width:parent.width
        height: parent.height
        active: false//loader是否激活
        source: "./PageMusicLyricDetail.qml"
        onLoaded: {
            item.y=musicLyricPage.height
        }
        ParallelAnimation{//并行动画
            id:showHideAni
            property double endY: 0
            property double endOpacity: 0
            NumberAnimation {
                target: musicLyricPage.item
                property: "y"
                to:showHideAni.endY
                duration: 300
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: musicLyricPage.item
                property: "opacity"
                to:showHideAni.endOpacity
                duration: 300
                easing.type: Easing.InOutQuad
            }
            onStopped: {
                if( musicLyricPage.item.y===musicLyricPage.height||musicLyricPage.item.opacity===0){
                    musicLyricPage.isShow=false
                    musicLyricPage.active=false

                }else if(musicLyricPage.item.y===0||musicLyricPage.item.opacity===1){
                    musicLyricPage.isShow=true
                    musicLyricPage.active=true
                    mainPage.visible=false
                }
            }
        }

        function hidePage(){//隐藏页面
            mainPage.visible=true
            showHideAni.endY=musicLyricPage.height
            showHideAni.endOpacity=0
            showHideAni.start()
        }
        function showPage(){//显示页面
            musicLyricPage.active=true
            showHideAni.endY=0
            showHideAni.endOpacity=1
            showHideAni.start()
        }
    }
}
