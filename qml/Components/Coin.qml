import QtQuick 2.12
import QtQuick.Window 2.12

import "qrc:/js/GameLogic.js" as GameLogic

Image {
    id: coin
    opacity: 0
    fillMode: Image.PreserveAspectFit
    source: "qrc:/images/coin.png"

    onYChanged: checkCoinCollision()

    property bool collected: false

    property int coinSpeedLow: 2000
    property int coinSpeedHigh: 3000

    function checkCoinCollision() {
        if (collected)
            return

        if (GameLogic.checkCollision(player, this)) {
            collected = true
            points++
            GameLogic.destroyObject(this)
        }
    }

    Component.onCompleted: {
        y = Screen.height - height - 100
        opacity = 1
    }

    Behavior on y {
        SequentialAnimation {
            PropertyAnimation {
                easing.type: Easing.InSine
                duration: GameLogic.getRandom(coinSpeedLow, coinSpeedHigh)
            }
            PropertyAnimation {
                easing.type: Easing.InSine
                properties: "y"
                to: Screen.height - 103 - coin.height
                duration: 500
            }
            PropertyAnimation {
                easing.type: Easing.InSine
                properties: "y"
                to: (Screen.height - 103 - coin.height) - GameLogic.getRandom(0, coin.height / 6)
                duration: 500
            }
            PropertyAnimation {
                easing.type: Easing.InSine
                properties: "y"
                to: Screen.height - 103 - coin.height
                duration: 500
            }
            ParallelAnimation {
                PropertyAnimation {
                    easing.type: Easing.InSine
                    properties: "y"
                    to: Screen.height
                    duration: 500
                }
                PropertyAnimation { target: coin; property: "opacity"; to: 0; duration: 500 }
            }
            ScriptAction { script: GameLogic.destroyObject(coin) }
        }
    }
}
