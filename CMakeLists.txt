cmake_minimum_required(VERSION 3.16)

project(QT_QUICK_LEARNING VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appQT_QUICK_LEARNING
    main.cpp
)

set(qml_files
    Main.qml
    ToDoList.qml
)

set(cpp_sources
    models/ToDoModel.cpp
    models/ToDoModel.h
)

qt_add_qml_module(appQT_QUICK_LEARNING
    URI QT_QUICK_LEARNING
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_sources}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appQT_QUICK_LEARNING PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appQT_QUICK_LEARNING
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQT_QUICK_LEARNING
    PRIVATE Qt6::Quick
)
target_link_libraries(appQT_QUICK_LEARNING PRIVATE Qt6::Core)

include(GNUInstallDirs)
install(TARGETS appQT_QUICK_LEARNING
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
