import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:leftBar
    property var leftBarData:
        [{headerText:"发现音乐",
            btnData:[
                {btnText:"乐库",btnIcon:"",qml:"",isActive:true},
                {btnText:"歌单",btnIcon:"",qml:"",isActive:true}
                ],
            isActive:true
            },
        {headerText:"我的音乐",
            btnData:[
                {btnText:"我的收藏",btnIcon:"",qml:"",isActive:true},
                {btnText:"最近播放",btnIcon:"",qml:"",isActive:true},
                {btnText:"本地音乐",btnIcon:"",qml:"",isActive:true},
                {btnText:"下载",btnIcon:"",qml:"",isActive:true}
                ],
            isActive:true
            }
        ]
    width: 180
    height: parent.height
    Flickable{//可滚动
        anchors.fill: parent
    }

    color: "BLUE"
}
