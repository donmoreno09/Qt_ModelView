cmake_minimum_required(VERSION 3.16)
project(ContactApp VERSION 1.0 LANGUAGES CXX)

# Qt modules we need
find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)

# Enable automatic MOC (Meta-Object Compiler) for Q_OBJECT classes
set(CMAKE_AUTOMOC ON)

# Create executable
qt_add_executable(ContactApp
    main.cpp
    ContactModel.h
    ContactModel.cpp
)

# Create QML module
qt_add_qml_module(ContactApp
    URI ContactApp
    VERSION 1.0
    QML_FILES Main.qml
)

# Link Qt libraries
target_link_libraries(ContactApp PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
)
