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
    title: qsTr("Hello World")

    QtObject{
        id:p_theme
        property int current: 0
        //分别为 默认主题、
        property var defaultTheme: [
            {name:"pink",type:"defult",backgroundColor:"#FAF2F1",
                subBackgroundColor:"#F2A49B",clickBackgroundColor:"#F6867A",
                fontColor:"#572920",subColor:"#FAF7F6"}
        ]
    }
    MusicResource{
        id:p_musicRes
    }

    MusicPlayer{
        id:p_musicPlayer
        source: p_musicRes.thisPlayMusicInfo.url
    }

    FavoriteManager{
        id:p_favoriteManager
        savePath: "userInfo/favoriteMusic.json"
    }

    Column{
        id:mainPage
        anchors.fill: parent

        TitleBar{
            id:titleBar
            width:parent.width
            height: 80
            color:thisTheme.backgroundColor
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
                    Component.onCompleted: {
                        let qml=leftBar.thisQml
                        let btnText=leftBar.thisBtnText
                        let func=()=>{
                            leftBar.thisQml=qml
                            leftBar.thisBtnText=btnText
                        }
                        rightContent.pushStep({name:btnText,callBack:func})
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


    // PageMusicLyricDetail{
    //     id:musicLyricPage
    // }


}
