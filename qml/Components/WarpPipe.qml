import QtQuick 2.12
import QtQuick.Window 2.12

import "qrc:/js/GameLogic.js" as GameLogic

Image {
    x: board.width/2 - width/2
    y: board.height
    fillMode: Image.PreserveAspectFit
    source: "qrc:/images/tube.png"

    Behavior on y {
        SequentialAnimation {
            PropertyAnimation { easing.type: Easing.InSine; duration: 1000 }
            PauseAnimation { duration: 2000 }
            ScriptAction { script: { player.movable = true } }
            PauseAnimation { duration: 3000 }
            PropertyAnimation { target: warpPipe; property: "y"; to: board.height }
        }
    }
}
