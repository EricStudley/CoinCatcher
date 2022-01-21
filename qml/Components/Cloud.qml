import QtQuick 2.12
import QtQuick.Window 2.12

import "qrc:/js/GameLogic.js" as GameLogic

Image {
    id: cloud
    fillMode: Image.PreserveAspectFit

    property int cloudSpeedLow: 12000
    property int cloudSpeedHigh: 17500

    property int coinSpawnSpeedLow: 1500
    property int coinSpawnSpeedHigh: 2500

    Component.onCompleted: {
        x = Screen.width
        state = (GameLogic.getRandom(1, 20) < 20) ? "normal" : "rainy"
    }

    Behavior on x {
        SequentialAnimation {
            PropertyAnimation {
                easing.type: Easing.Linear
                duration: GameLogic.getRandom(cloudSpeedLow, cloudSpeedHigh)
            }
            ScriptAction { script: GameLogic.destroyObject(cloud) }
        }
    }

    Timer {
        id: fallingCoinTimer
        repeat: true
        running: true
        interval: GameLogic.getRandom(coinSpawnSpeedLow, coinSpawnSpeedHigh)
                  * (cloud.state == "normal" ? 1 : 0.1)

        onTriggered: {
            const size = (cloud.state == "normal") ? 70 : 30
            const x = cloud.x, y = cloud.y, w = cloud.width, h = cloud.height
            GameLogic.createCoin(GameLogic.getRandom(x + w/6, x + w - w/6),
                                 GameLogic.getRandom(y + h/6, y + h - h/6),
                                 size)
        }
    }
}
