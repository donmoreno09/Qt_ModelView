import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import QT_Quick_ModelView 1.0


ColumnLayout {
    Frame {
        Layout.fillWidth: true

        ListView {
            anchors.fill: parent
            implicitWidth: 250
            implicitHeight: 250
            clip: true

            model: ToDoModel {
                // list: ToDoList
            }

            delegate: RowLayout {
                width: parent.width

                CheckBox {
                    checked: model.done
                    onClicked: model.done = checked
                }
                TextField {
                    text: model.description
                    onEditingFinished: model.description = text
                    Layout.fillWidth: true
                }
            }
        }
    }

    RowLayout {
        Button {
            text: "ADD NEW ITEM"
            Layout.fillWidth: true

            onClicked: ToDoList.appendItem()
        }
        Button {
            text: "REMOVE COMPLETED"
            Layout.fillWidth: true

            onClicked: ToDoList.removeCompletedItem()
        }
    }
}
