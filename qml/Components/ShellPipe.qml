import QtQuick 2.12
import QtQuick.Window 2.12

import "qrc:/js/GameLogic.js" as GameLogic

Image {
    id: shellPipe
    z: 100
    fillMode: Image.PreserveAspectFit
    source: "qrc:/images/tube.png"

    property string direction: ""

    Component.onCompleted: {
        switch (direction) {
        case "bottom":
            y = Screen.height - height - 103
            break
        case "left":
            rotation = 90
            x = 0
            break
        case "right":
            rotation = 270
            x = Screen.width - height + 20
            break
        }
    }

    Behavior on x {
        SequentialAnimation {
            PropertyAnimation { easing.type: Easing.InSine; duration: 1000 }
            PauseAnimation { duration: 3000 }
            PropertyAnimation {
                target: shellPipe
                property: "x"
                to: direction == "left" ? -shellPipe.height
                                        : Screen.width + 20
            }
            ScriptAction { script: GameLogic.destroyObject(shellPipe) }
        }
    }
    Behavior on y {
        SequentialAnimation {
            PropertyAnimation { easing.type: Easing.InSine; duration: 1000 }
            PauseAnimation { duration: 3000 }
            PropertyAnimation { target: shellPipe; property: "y"; to: Screen.height }
            ScriptAction { script: GameLogic.destroyObject(shellPipe) }
        }
    }
}
