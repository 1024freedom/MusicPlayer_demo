import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:rightContent
    property string thisQml: ""
    Loader{
        source: rightContent.thisQml
        onStatusChanged: {
            if(status===Loader.Ready){
                item.parent=parent
            }
        }
    }
}
