import QtQuick 2.14
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14

import "Components"

import "qrc:/js/GameLogic.js" as GameLogic

ApplicationWindow {
    id: board
    visible: true
//    visibility: Window.FullScreen
    width: 1920
    height: 1080
    color: "black"
    title: qsTr("Coin Catcher")

    signal clearBricks()

    property int playerSpeed: 100

    property int points: 0
    property int score: 0

    property int livesLost: 0
    property int heartCount: 5

    property int prevDirection: 3

    property bool gameOver: livesLost >= heartCount

    onLivesLostChanged: {
        if (livesLost >= heartCount) {
            GameLogic.gameOver()
        }
    }

    Component.onCompleted: GameLogic.gameStart()

    Timer {
        repeat: true
        running: !gameOver
        interval: GameLogic.getRandom(cloudSpawnSpeedLow, cloudSpawnSpeedHigh)

        property int cloudSpawnSpeedLow: 3000
        property int cloudSpawnSpeedHigh: 5500

        onTriggered: GameLogic.createRandomCloud()
    }

    Timer {
        id: shellPipeTimer
        repeat: true
        running: false
        interval: GameLogic.getRandom(shellSpawnLow, shellSpawnHigh)

        property int shellSpawnLow: 2000
        property int shellSpawnHigh: 3000

        onTriggered: {
            var dir

            do dir = GameLogic.getRandom(1, 3)
            while (dir === prevDirection)

            prevDirection = dir

            if (dir === 1)
                GameLogic.createShellPipe(-182, GameLogic.getRandom(board.height/10.8, board.height/1.35), "left")
            else if (dir === 2)
                GameLogic.createShellPipe(board.width, GameLogic.getRandom(board.height/10.8, board.height/1.35), "right")
            else
                GameLogic.createShellPipe(GameLogic.getRandom(0, board.width - 182), board.height, "bottom")
        }
    }

    Image {
        id: background
        anchors { fill: parent }
        source: "qrc:/images/cc_background.png"
    }

    RowLayout {
        visible: !gameOver
        anchors { left: parent.left; top: parent.top; margins: 64 }

        Image {
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/coin.png"
        }

        Text {
            font.pixelSize: 54
            color: "white"
            text: points
        }
    }

    RowLayout {
        visible: !gameOver
        anchors { right: parent.right; top: parent.top; margins: 64 }

        Repeater {
            model: heartCount

            Image {
                fillMode: Image.PreserveAspectFit
                source: index >= livesLost ? "qrc:/images/heart-on.png"
                                           : "qrc:/images/heart-off.png"
            }
        }
    }

    MouseArea {
        anchors { fill: parent }
        hoverEnabled: true
        cursorShape: Qt.BlankCursor

        onMouseXChanged: (mouse) => player.updatePosition(mouse)

        onMouseYChanged: (mouse) => player.updatePosition(mouse)
    }

    GameOverPopup {
        id: gameOverPopup
        visible: gameOver
    }

    Player {
        id: player

        onXChanged: shellPipeTimer.start()
    }

    WarpPipe {
        id: warpPipe
    }

    Image {
        z: 1000
        anchors { fill: parent }
        source: "qrc:/images/cc_ground.png"
    }
}
