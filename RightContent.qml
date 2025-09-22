import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:rightContent
    property string thisQml: "PageFindMusic.qml"
    Loader{
        source: rightContent.thisQml
        onStateChanged: {
            if(status===Loader.Ready){
                item.parent=parent
            }
        }
    }
}
