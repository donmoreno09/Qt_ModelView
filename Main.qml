import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("ModelView")

    Item {
        anchors.fill: parent
        anchors.margins: 16

        ToDoListView {
            anchors.fill: parent
        }
    }
}
