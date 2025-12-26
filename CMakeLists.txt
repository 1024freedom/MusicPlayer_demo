cmake_minimum_required(VERSION 3.16)

project(MusicPlayer_demo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


find_package(Qt6 6.2 COMPONENTS Quick REQUIRED)
#添加
set(CMAKE_AUTORCC ON)
find_package(Qt6 REQUIRED COMPONENTS Quick QuickEffects Multimedia)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Qml Sql)
find_package(OpenMP)
find_package(Qt6 REQUIRED COMPONENTS Concurrent)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
#
qt_add_executable(appMusicPlayer_demo
    main.cpp
)

qt_add_qml_module(appMusicPlayer_demo
    URI MusicPlayer_demo
    VERSION 1.0
    QML_FILES main.qml
    SOURCES framelesswindow.h framelesswindow.cpp
    RESOURCES source.qrc
    QML_FILES TitleBar.qml
    QML_FILES LeftBar.qml
    QML_FILES RightContent.qml
    QML_FILES BottomBar.qml
    QML_FILES
    QML_FILES ToolTipButtom.qml
    QML_FILES RoundImage.qml
    QML_FILES PageFindMusic.qml
    QML_FILES NewMusicContent.qml
    QML_FILES PlayListContent.qml
    QML_FILES MusicResource.qml
    QML_FILES PlayListLable.qml
    QML_FILES PlayListDetail.qml
    QML_FILES MusicPlayer.qml
    QML_FILES BottomBarVolumeBtn.qml
    QML_FILES ThisPlayerListLabel.qml
    QML_FILES PageMusicLyricDetail.qml
    QML_FILES LyricListView.qml
    SOURCES favoritemanager.h favoritemanager.cpp
    QML_FILES PageFavoriteMusicDetail.qml
    SOURCES desktoplyric.h desktoplyric.cpp
    QML_FILES DeskTopLyric.qml
    SOURCES imagecolor.h imagecolor.cpp
    QML_FILES BackgroundManager.qml
    QML_FILES
    QML_FILES
    QML_FILES
    QML_FILES
    SOURCES thememanager.h thememanager.cpp
    QML_FILES PageThemeChoose.qml
    QML_FILES ThemeButton.qml
    QML_FILES TitleBarSearchBox.qml
    QML_FILES PageSearchResult.qml
    QML_FILES PagePlayHistory.qml
    SOURCES playhistorymanager.h playhistorymanager.cpp
    QML_FILES BottomImage.qml
    SOURCES musicdownload.h musicdownload.cpp
    SOURCES downloadtaskthread.h downloadtaskthread.cpp
    SOURCES downloadtask.h downloadtask.cpp
    QML_FILES PageDownload.qml
    QML_FILES ThemePreviewIcon.qml
    QML_FILES ThemeImage.qml
    QML_FILES DownloadButton.qml
    QML_FILES Toast.qml
    SOURCES
    SOURCES localmusicmanager.h localmusicmanager.cpp
    QML_FILES PageLocalMusic.qml
    QML_FILES TextButton.qml
    SOURCES musicsearch.h musicsearch.cpp
    SOURCES musicspectrumplayer.h musicspectrumplayer.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appMusicPlayer_demo PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appMusicPlayer_demo
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)







target_link_libraries(appMusicPlayer_demo PRIVATE Qt6::Quick)
target_link_libraries(appMusicPlayer_demo PRIVATE Qt6::Core)
target_link_libraries(appMusicPlayer_demo PRIVATE Qt6::Qml Qt6::Sql)
target_link_libraries(appMusicPlayer_demo PRIVATE Qt6::Concurrent)
target_link_libraries(appMusicPlayer_demo PRIVATE Qt6::Quick Qt6::Multimedia)
if(OpenMP_CXX_FOUND)
    message("支持openMP")
    target_link_libraries(appMusicPlayer_demo PUBLIC OpenMP::OpenMP_CXX)
else()
    message("不支持")
endif()

include(GNUInstallDirs)
install(TARGETS appMusicPlayer_demo
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
