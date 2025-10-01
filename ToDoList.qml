import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

Frame {
    ListView{
        implicitWidth: 250
        implicitHeight: 300
        clip: true

        model: ListModel {
            ListElement {
                done: true
                description: "Washes the car"
            }
            ListElement {
                done: false
                description: "Do the dishes"
            }
            ListElement {
                done: true
                description: "Fix the sink"
            }
        }

        delegate: RowLayout {
            width: parent.width

            CheckBox {
                checked: model.done
            }

            TextField {
                Layout.fillWidth: true
                text: model.description
            }
        }
    }
}
