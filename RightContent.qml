import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:rightContent
    property string thisQml: ""
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    color:  thisTheme.subColor
    Loader{
        source: rightContent.thisQml
        onStatusChanged: {
            if(status===Loader.Ready){
                item.parent=parent
            }
        }
    }
}
