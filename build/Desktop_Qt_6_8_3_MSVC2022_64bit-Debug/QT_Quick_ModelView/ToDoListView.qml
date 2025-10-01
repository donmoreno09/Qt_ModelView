import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QT_Quick_ModelView 1.0

Item {
    width: 300
    height: 400

    ToDoList { id: todoList }  // Create the list instance

    ColumnLayout {
        anchors.fill: parent

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                anchors.fill: parent
                clip: true

                model: ToDoModel {
                    list: todoList  // Pass it to the model
                }

                delegate: RowLayout {
                    width: if(parent) parent.width

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
            Layout.fillWidth: true

            Button {
                text: "ADD NEW ITEM"
                Layout.fillWidth: true
                onClicked: todoList.appendItem()
            }
            Button {
                text: "REMOVE COMPLETED"
                Layout.fillWidth: true
                onClicked: todoList.removeCompletedItems()
            }
        }
    }
}
