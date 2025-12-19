import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle{
    id:root
    property alias text: messageLabel.text
    property var thisTheme:p_theme.m_currentTheme
    //停留时间
    property int duration: 2000
    color: "#CC000000" // 半透明黑色
    property color textColor: thisTheme.disabledTextColor
    radius: height/2
    //根据文字宽度自动调整背景宽度
    width: messageLabel.implicitWidth+50
    height: 40

    opacity: 0
    visible: opacity>0

    z:999
    anchors.centerIn: parent
    Text{
        id:messageLabel
        anchors.centerIn: parent
        color: root.textColor
        font.pointSize: 14
    }
    //durationTime为可选参数
    function show(msg,durationTime){
        text=msg
        if(durationTime){
            animPause.duration=durationTime
        }else{
            animPause.duration=root.duration
        }
        anim.restart()
    }

    //动画
    SequentialAnimation{
        id:anim
        //快速淡入

        NumberAnimation {
            target: root
            property: "opacity"
            to:1
            duration: 200
            easing.type: Easing.OutQuad
        }
        //停留显示

        PauseAnimation {
            id:animPause
            duration: root.duration
        }
        //慢慢淡出

        NumberAnimation {
            target: root
            property: "opacity"
            to:0
            duration: 500
            easing.type: Easing.InQuad
        }
    }
}
