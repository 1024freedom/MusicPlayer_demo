cmake_minimum_required(VERSION 3.16)

project(MusicPlayer_demo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


find_package(Qt6 6.2 COMPONENTS Quick REQUIRED)
#添加
set(CMAKE_AUTORCC ON)
find_package(Qt6 REQUIRED COMPONENTS Quick QuickEffects)
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
    QML_FILES Image.qml
    QML_FILES ToolTipButtom.qml
    QML_FILES RoundImage.qml
    QML_FILES PageFindMusic.qml
    QML_FILES NewMusicContent.qml
    QML_FILES PlayListContent.qml
    QML_FILES MusicResource.qml
    QML_FILES PlayListLable.qml
    QML_FILES PlayListDetail.qml
    QML_FILES MusicPlayer.qml
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

target_link_libraries(appMusicPlayer_demo
    PRIVATE Qt6::Quick)

include(GNUInstallDirs)
install(TARGETS appMusicPlayer_demo
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
