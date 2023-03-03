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
            y = board.height - height
            break
        case "left":
            rotation = 90
            x = 0
            break
        case "right":
            rotation = 270
            x = board.width - height + 20
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
                                        : board.width + 20
            }
            ScriptAction { script: shellPipe.destroy() }
        }
    }
    Behavior on y {
        SequentialAnimation {
            PropertyAnimation { easing.type: Easing.InSine; duration: 1000 }
            PauseAnimation { duration: 3000 }
            PropertyAnimation { target: shellPipe; property: "y"; to: board.height }
            ScriptAction { script: shellPipe.destroy() }
        }
    }
}
