var coinComponent = Qt.createComponent("qrc:/qml/Components/Coin.qml")
var cloudComponent = Qt.createComponent("qrc:/qml/Components/Cloud.qml")
var shellPipeComponent = Qt.createComponent("qrc:/qml/Components/ShellPipe.qml")
var shellComponent = Qt.createComponent("qrc:/qml/Components/Shell.qml")
var brickComponent = Qt.createComponent("qrc:/qml/Components/Brick.qml")

function checkCollision(a, b) {
    return !((a.y + a.height < b.y)
             || (a.y > b.y + b.height)
             || (a.x + a.width < b.x)
             || (a.x > b.x + b.width))
}

function getRandom(minimum, maximum){
    var now = new Date()
    return Math.floor(Math.random(now.getSeconds()) * (maximum - minimum + 1)) + minimum
}

function getRotation(fromPosition, toPosition) {
    var rotation = Math.atan2(toPosition.y - fromPosition.y, toPosition.x - fromPosition.x)
    rotation = rotation * (180 / Math.PI)

    if (rotation < 0) {
        rotation = 360 + rotation
    }

    return 90 + rotation
}

function createCoin(x, y, size) {
    coinComponent.createObject(board, {"x": x, "y": y, "width": size, "height": size})
}

function createCloud(x, y, width) {
    const type = getRandom(1, 3)
    cloudComponent.createObject(board, {"x": x, "y": y, "width": width,
                                    "source": "qrc:/images/cloud_0" + type + ".png"})
}

function createRandomCloud() {
    createCloud(-250, getRandom(0, board.height/5.4), getRandom(150, 500))
}

function createShell(x, y) {
    shellComponent.createObject(board, {"x": x, "y": y})
}

function createShellPipe(x, y, direction) {
    shellPipeComponent.createObject(board, {"x": x, "y": y, "direction": direction})

    if (direction === "left") y += 50
    else if (direction === "right") y += 50
    else if (direction === "bottom") x += 40

    shellComponent.createObject(board, {"x": x, "y": y, "direction": direction})
}

function createBricks() {
    var b1 = brickComponent.createObject(board, {"x": getRandom(board.width/7.68, board.width/5.91),
                                             "y": getRandom(board.height/2.4, board.height/1.96)})
    brickComponent.createObject(board, {"x": b1.x + b1.width, "y": b1.y})
    brickComponent.createObject(board, {"x": b1.x + b1.width*2, "y": b1.y})

    var b2 = brickComponent.createObject(board, {"x": getRandom(board.width/2.02, board.width/1.75),
                                             "y": getRandom(board.height/2.8, board.height/2.1)})
    brickComponent.createObject(board,{"x": b2.x + b2.width, "y": b2.y})

    var b3 = brickComponent.createObject(board, {"x": getRandom(board.width/1.51, board.width/1.37),
                                             "y": getRandom(board.height/2.4, board.height/1.96),
                                             "source": "qrc:/images/brick-question.png"})
    brickComponent.createObject(board, {"x": b3.x + b3.width, "y": b3.y})
    brickComponent.createObject(board, {"x": b3.x + b3.width*2, "y": b3.y})
}

function gameStart() {
    clearBricks()
    createBricks()

    points = 0
    livesLost = 0

    var oldSpeed = playerSpeed
    playerSpeed = 3000
    player.visible = true
    player.movable = true
    player.y = board.height - player.height - 290
    warpPipe.y = board.height - 103 - warpPipe.height
    playerSpeed = oldSpeed
}

function gameOver() {
    shellPipeTimer.stop()

    score = points

    player.visible = false
    player.movable = false
    player.x = board.width/2 - player.width/2
    player.y = board.height + 200
    warpPipe.y = board.height
}

function destroyObject(object) {
    object.destroy()
}
