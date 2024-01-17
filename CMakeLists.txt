cmake_minimum_required(VERSION 3.16)

project(Calibration3D VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 7.0 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(appCalibration3D
    main.cpp
)

qt_add_qml_module(appCalibration3D
    URI Calibration3D
    VERSION 1.0
    QML_FILES Main.qml
    QML_FILES qml/MainLayOut.qml
    QML_FILES qml/MainShowView.qml
    QML_FILES qml/DataViewItem.qml
    SOURCES filecontent.h filecontent.cpp
    QML_FILES qml/core/FileContentTool.qml
    QML_FILES qml/core/Core.qml
    QML_FILES qml/DataListView.qml
    QML_FILES qml/DataListViewItem.qml
    QML_FILES qml/Labels/BaseLabel.qml qml/Labels/FontGrade.qml
    QML_FILES qml/Adjust/AdjustView.qml
    RESOURCES qtquickcontrols2.conf
    QML_FILES qml/Adjust/SpinBoxItem.qml
)

set_target_properties(appCalibration3D PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appCalibration3D
    PRIVATE Qt6::Quick
)

install(TARGETS appCalibration3D
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
