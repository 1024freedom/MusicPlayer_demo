import QtQuick
import sz.window
import QtQuick.Layouts
Rectangle{
    id:rightContent
    property string thisQml: ""
    property var thisTheme: p_theme.defaultTheme[p_theme.current]
    property alias loadItem: rightContentLoader.item
    color:  thisTheme.subColor
    Loader{
        id:rightContentLoader
        source: rightContent.thisQml
        onLoaded: {
            item.parent=parent

        }
    }
}
