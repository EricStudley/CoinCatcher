import QtQuick 2.12
import QtQuick.Window 2.12

import "qrc:/js/GameLogic.js" as GameLogic

Image {
    id: shell
    state: "center"
    source: "qrc:/images/shell" + state + ".png"

    property int shellSpeed: 1500

    property string direction: ""
    property bool crashed: false

    onXChanged: checkShellCollision()

    onYChanged: checkShellCollision()

    Component.onCompleted: {
        switch (direction) {
        case "left": x = board.width; break
        case "right": x = -width; break
        default: y = board.height / 6; break
        }
    }

    function checkShellCollision() {
        if (crashed) {
            return
        }

        if (GameLogic.checkCollision(player, this)) {
            crashed = true
            opacity = 0
            livesLost++
        }
    }

    Behavior on opacity {
        SequentialAnimation {
            PropertyAnimation{ duration: 300 }
            ScriptAction { script: shell.destroy() }
        }
    }

    Behavior on x {
        SequentialAnimation {
            PauseAnimation { duration: 1000 }
            PropertyAnimation { duration: shellSpeed }
            ScriptAction { script: shell.destroy() }
        }
    }

    Behavior on y {
        SequentialAnimation {
            PauseAnimation { duration: 1000 }
            PropertyAnimation {
                easing.type: Easing.OutSine
                duration: shellSpeed / 2
            }
            PropertyAnimation {
                target: shell
                easing.type: Easing.InSine
                property: "y"
                to: board.height
                duration: shellSpeed / 2
            }
            ScriptAction { script: shell.destroy() }
        }
    }

    Timer {
        id: spinTimer
        repeat: true
        running: true
        interval: 50

        onTriggered: {
            switch(shell.state) {
            case "center": shell.state = "left"; break
            case "left": shell.state = "back"; break
            case "back": shell.state = "right"; break
            case "right": shell.state = "center"; break
            }
        }
    }
}
