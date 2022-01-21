import QtQuick 2.12
import QtQuick.Window 2.12

import "qrc:/js/GameLogic.js" as GameLogic

Image {
    id: player
    x: Screen.width / 2 - width / 2
    y: Screen.height + 200
    fillMode: Image.PreserveAspectFit
    source: "qrc:/images/flower-" + state + ".png"
    state: "closed"

    property bool movable: false

    onMovableChanged: rotation = 0

    function updatePosition(mouse) {
        x = mouse.x - width / 2
        y = mouse.y - height / 2
        var fromPosition = Qt.point(x + width / 2, y + height / 2)
        rotation = GameLogic.getRotation(fromPosition, mouse)
    }

    Behavior on x { PropertyAnimation { duration: playerSpeed } }
    Behavior on y { PropertyAnimation { duration: playerSpeed } }

    Timer {
        repeat: true
        running: true
        interval: 200

        onTriggered: parent.state = (parent.state === "closed" ? "opened" : "closed")
    }
}
