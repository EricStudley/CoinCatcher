import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "qrc:/js/GameLogic.js" as GameLogic

Item {
    anchors { fill: parent }

    Behavior on opacity { PropertyAnimation { duration: 500 } }

    ColumnLayout {
        anchors { centerIn: parent }

        Image {
            Layout.alignment: Qt.AlignHCenter
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/skull.png"
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 72
            color: "black"
            text: "GAME OVER"
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 63
            color: "black"
            text: "Score " + score
        }
    }

    MouseArea {
        anchors { fill: parent }

        onClicked: GameLogic.gameStart()
    }
}
