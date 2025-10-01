import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Learning QT")

    ToDoList {
        anchors.centerIn: parent
    }
}
