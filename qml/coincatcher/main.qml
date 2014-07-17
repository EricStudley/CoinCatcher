import QtQuick 2.0

Item {
    id: board

    // Hardcoded for use outside of the Kiosk.
    height: 900
    width: 1600

    signal clearBricks()

    property int catcherSpeed: 100

    property int coinSpeedLow: 2000
    property int coinSpeedHigh: 3000
    property int coinSpawnSpeedLow: 1500
    property int coinSpawnSpeedHigh: 2500

    property int cloudSpeedLow: 12000
    property int cloudSpeedHigh: 17500
    property int cloudSpawnSpeedLow: 3000
    property int cloudSpawnSpeedHigh: 5500

    property int shellSpeed: 1500
    property int shellSpawnLow: 2000
    property int shellSpawnHigh: 3000

    property int points: 0
    property int score: 0

    property int livesLost: 0
    property int heartCount: 5

    property int prevDirection: 3

    onLivesLostChanged: {
        if (livesLost >= heartCount)
            gameOver();
    }

    Component.onCompleted: gameStart()

    Image {
        id: background
        anchors.fill: parent
        z: -100

        asynchronous: false
        fillMode: Image.PreserveAspectFit
        source: "images/cc_background.png"
    }

    // The ground is a separate image so that coins can fall behind it and off screen.
    Image {
        id: backgroundGround
        anchors.bottom: parent.bottom
        z: 20

        asynchronous: false
        fillMode: Image.PreserveAspectFit
        source: "images/cc_ground.png"
    }

    Image {
        id: close
        anchors {
            top: parent.top
            right: parent.right
        }
        z: 20

        asynchronous: false
        fillMode: Image.PreserveAspectFit
        source: "images/cloud_close.png"

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    Rectangle {
        id: heartCounter
        anchors {
            left: parent.left
            leftMargin: 50
            top: parent.top
            topMargin: 50
        }
        width: 375
        z: 100

        Repeater {
            model: heartCount

            Image {
                width: 75
                x: index * 60
                fillMode: Image.PreserveAspectFit
                source: (index >= livesLost) ? "images/heart-on.png" : "images/heart-off.png"
            }
        }
    }

    Image {
        id: coinCounter
        anchors {
            top: parent.top
            topMargin: parent.height * 0.033
            right: close.left
            rightMargin: parent.width * 0.05
        }
        height: 70

        fillMode: Image.PreserveAspectFit
        source: "images/coin.png"

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.right
                leftMargin: board.width * 0.015
            }
            font.pixelSize: 54
            color: "white"
            text: points
        }
    }

    Item {
        id: gameOverScore
        anchors.fill: parent
        z: 100
        enabled: false
        opacity: enabled ? 1 : 0

        Behavior on opacity { PropertyAnimation { duration: 500 } }

        MouseArea {
            id: resetButton
            anchors.fill: parent
            onClicked: gameStart()
        }

        Image {
            id: skull
            anchors {
                bottom: gameOverText.top
                bottomMargin: parent.height/12
                horizontalCenter: parent.horizontalCenter
            }
            width: 200
            fillMode: Image.PreserveAspectFit
            source: "images/skull.png"
        }

        Text {
            id: gameOverText
            anchors.centerIn: parent
            font.pixelSize: 72
            color: "black"
            text: "GAME OVER"
        }

        Text {
            id: scoreText
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: gameOverText.bottom
                topMargin: parent.height/12
            }
            font.pixelSize: 63
            color: "black"
            text: "Score " + score
        }
    }

    MouseArea {
        anchors.fill: parent

        // When the touchpoint's X and Y are changed, the catcher moves to that X and Y.
        // The shellPipe timer is started on first touch of screen.
        hoverEnabled: true
        onMouseXChanged: catcher.updatePosition(mouseX, mouseY)
        onMouseYChanged: catcher.updatePosition(mouseX, mouseY)
    }

    // Coin component: coins are spawned at a random position in a cloud, and fall to the ground.
    Component {
        id: coinComp

        Image {
            id: coin
            opacity: 0
            fillMode: Image.PreserveAspectFit
            source: "images/coin.png"

            // On Y changed: If a collision with the catcher is detected,
            // the player gets a point and the coin is destroyed.
            onYChanged: checkCoinCollision()

            property bool collected: false

            function checkCoinCollision() {
                if (collected)
                    return;

                if (checkCollision(catcher, coin)) {
                    collected = true;
                    points++;
                    destroyObject(coin);
                }
            }

            // Behavior on y changed: coins will fall to the ground and bounce up and down
            // slightly before disappearing off screen and being destroyed.
            Behavior on y {
                SequentialAnimation {
                    PropertyAnimation { easing.type: Easing.InSine;
                        duration: getRandom(coinSpeedLow, coinSpeedHigh) }
                    PropertyAnimation { easing.type: Easing.InSine; properties: "y";
                        to: (board.height - backgroundGround.height - coin.height); duration: 500 }
                    PropertyAnimation { easing.type: Easing.InSine; properties: "y";
                        to: (board.height - backgroundGround.height - coin.height)
                            - getRandom(0, coin.height/6); duration: 500 }
                    PropertyAnimation { easing.type: Easing.InSine; properties: "y";
                        to: (board.height - backgroundGround.height - coin.height); duration: 500 }
                    ParallelAnimation {
                        PropertyAnimation { easing.type: Easing.InSine; properties: "y";
                            to: board.height; duration: 500 }
                        PropertyAnimation { target: coin; property: "opacity"; to: 0; duration: 500 }
                    }
                    ScriptAction { script: destroyObject(coin) }
                }
            }

            // When a coin is created, it fades in from opacity 0->1 and has it's Y value
            // changed to the bottom of the screen, which starts the Behavior on Y element.
            Component.onCompleted: {
                coin.y = board.height - coin.height - 100;
                coin.opacity = 1;
            }
        }
    }

    // Cloud component: clouds are spawned at a random height on the top left of the screen,
    // then travel across the screen dropping coins at random intervals.
    Component {
        id: cloudComp

        Image {
            id: cloud
            fillMode: Image.PreserveAspectFit

            // Behavior on X changed: clouds float across screen at
            // random duration, then get destroyed.
            Behavior on x {
                SequentialAnimation {
                    PropertyAnimation {
                        easing.type: Easing.Linear
                        duration: getRandom(cloudSpeedLow, cloudSpeedHigh)
                    }
                    ScriptAction { script: destroyObject(cloud) }
                }
            }

            // Coin timer: creates coins inside the cloud.
            Timer {
                id: coinTimer
                repeat: true
                running: true
                interval: getRandom(coinSpawnSpeedLow, coinSpawnSpeedHigh)
                          * (cloud.state == "normal" ? 1 : 0.1)

                onTriggered: {
                    const size = (cloud.state == "normal") ? 70 : 30;
                    const x = cloud.x, y = cloud.y, w = cloud.width, h = cloud.height;
                    createCoin(getRandom(x + w/6, x + w - w/6),
                               getRandom(y + h/6, y + h - h/6), size);
                }
            }

            // When a cloud is created, it's X value is set to the other side of the screen,
            // which starts the Behavior on X element.
            Component.onCompleted: {
                cloud.x = board.width;
                cloud.state = (getRandom(1, 20) < 20) ? "normal" : "rainy";
            }
        }
    }

    // Cloud spawn timer: spawns clouds off the screen at random intervals.
    Timer {
        id: cloudSpawnTimer
        repeat: true
        running: !gameOverScore.enabled
        interval: getRandom(cloudSpawnSpeedLow, cloudSpawnSpeedHigh)

        onTriggered: {
            createCloud(-250, getRandom(0, parent.height/5.4), getRandom(150, 500));
        }
    }

    // Shell component: a shell spawns inside a shell pipe, and launches across
    // the screen oposite the shell pipe.
    Component {
        id: shellComp

        Image {
            id: shell
            width: 75
            height: width

            state: "center"
            source: "images/shell" + shell.state + ".png"

            property string direction: ""
            property bool crashed: false

            // On X and Y changed: if a collision with the catcher is detected,
            // the player loses a life and the shell is destroyed.
            onXChanged: checkShellCollision()
            onYChanged: checkShellCollision()

            function crash() {
                shell.crashed = true;
                shell.opacity = 0;
            }

            function checkShellCollision() {
                if (shell.crashed)
                    return;

                if (checkCollision(catcher, shell)) {
                    shell.crash();
                    livesLost++;
                }
            }

            Behavior on opacity {
                SequentialAnimation {
                    PropertyAnimation{ duration: 300 }
                    ScriptAction { script: destroyObject(shell) }
                }
            }

            // Behavior on X changed: the shell is paused while the shellPipe animates,
            // then is sent across the screen.
            Behavior on x {
                SequentialAnimation {
                    PauseAnimation { duration: 1000 }
                    PropertyAnimation { duration: shellSpeed }
                    ScriptAction { script: destroyObject(shell) }
                }
            }

            // Behavior on Y changed: the shell is paused while the shellPipe animates,
            // then is sent up the screen then back down.
            Behavior on y {
                SequentialAnimation {
                    PauseAnimation { duration: 1000 }
                    PropertyAnimation { easing.type: Easing.OutSine; duration: shellSpeed/2 }
                    PropertyAnimation { easing.type: Easing.InSine; target: shell; property: "y";
                        to: board.height; duration: shellSpeed/2 }
                    ScriptAction { script: destroyObject(shell) }
                }
            }

            // Spin timer: switches the images of the shell rapidly, making the shell "spin".
            Timer {
                id: spinTimer
                repeat: true
                running: true
                interval: 50

                onTriggered: {
                    if (shell.state == "center")
                        shell.state = "left";
                    else if (shell.state == "left")
                        shell.state = "back";
                    else if (shell.state == "back")
                        shell.state = "right";
                    else if (shell.state == "right")
                        shell.state = "center";
                }
            }

            // If the shell is coming from:
            // - left, it goes to the right;
            // - right, it goes left;
            // - bottom, it goes up.
            Component.onCompleted: {
                if (direction == "left")
                    shell.x = board.width;
                else if (direction == "right")
                    shell.x = -shell.width;
                else
                    shell.y = board.height/6;
            }
        }
    }

    // Shell Pipe component: Shell pipes are spawned at a random interval on the left,
    // bottom, and right sides. Each shell pipe will be on a different side then the last.
    Component {
        id: shellPipeComp

        Image {
            id: shellPipe
            height: 182
            z: 10

            fillMode: Image.PreserveAspectFit
            source: "images/tube.png"

            property string direction: ""

            // Behavior on X and Y: the pipe will appear on the side it's supposed to,
            // pop out, launch the shell, then return off-screen.
            Behavior on x {
                SequentialAnimation {
                    PropertyAnimation { easing.type: Easing.InSine; duration: 1000 }
                    PauseAnimation { duration: 3000 }
                    PropertyAnimation {
                        target: shellPipe
                        property: "x"
                        to: (shellPipe.direction == "left") ? -shellPipe.height : board.width+20
                    }
                    ScriptAction { script: destroyObject(shellPipe) }
                }
            }
            Behavior on y {
                SequentialAnimation {
                    PropertyAnimation { easing.type: Easing.InSine; duration: 1000 }
                    PauseAnimation { duration: 3000 }
                    PropertyAnimation { target: shellPipe; property: "y"; to: board.height }
                    ScriptAction { script: destroyObject(shellPipe) }
                }
            }

            // Sets the X/Y to change based on direction, which starts Behavior on X/Y element.
            // Rotation is changed as well.
            Component.onCompleted: {
                if (direction == "bottom") {
                    shellPipe.y = board.height - shellPipe.height - backgroundGround.height;
                }
                else if (direction == "left") {
                    shellPipe.rotation = 90;
                    shellPipe.x = 0;
                }
                else if (direction == "right") {
                    shellPipe.rotation = 270;
                    shellPipe.x = board.width - shellPipe.height + 20;
                }
            }
        }
    }

    // Shell pipe timer: creates pipes that launch shells at random intervals.
    // Will never send a shell from the same side twice in a row.
    Timer {
        id: shellPipeTimer
        repeat: true
        running: false
        interval: getRandom(shellSpawnLow, shellSpawnHigh)

        onTriggered: {
            var dir;
            do dir = getRandom(1, 3);
            while (dir === prevDirection);
            prevDirection = dir;

            if (dir === 1)
                createShellPipe(-182, getRandom(board.height/10.8, board.height/1.35), "left");
            else if (dir === 2)
                createShellPipe(board.width, getRandom(board.height/10.8, board.height/1.35), "right");
            else
                createShellPipe(getRandom(0, board.width - 182), board.height, "bottom");
        }
    }

    // Brick component: bricks are loaded when the game is launched,
    // and will harm a player when touched.
    Component {
        id: brickComp

        Image {
            id: brick
            width: 69
            height: width
            source: "images/brick.png"

            property bool crashed: false

            Behavior on opacity {
                SequentialAnimation{
                    PropertyAnimation{ duration: 400 }
                    ScriptAction { script: destroyObject(brick) }
                }
            }

            function crash() {
                brick.crashed = true;
                brick.opacity = 0;
            }

            function checkBrickCollision() {
                if (brick.crashed)
                    return;

                if (checkCollision(catcher, brick)){
                    brick.crash();
                    livesLost++;
                }
            }

            Connections {
                target: catcher
                onXChanged: brick.checkBrickCollision()
                onYChanged: brick.checkBrickCollision()
            }

            Connections {
                target: board
                onClearBricks: brick.crash()
            }
        }
    }

    // Catcher: this is the plant the player controls.
    Image {
        id: catcher
        x: board.width/2 - width/2
        y: board.height + 200
        width: 83
        height: 114

        fillMode: Image.PreserveAspectFit
        source: "images/flower-" + catcher.state + ".png"

        state: "closed"

        property bool movable: false

        // The catcher moves to catch up to touchpoint at catcherSpeed.
        Behavior on x { PropertyAnimation { duration: catcherSpeed } }
        Behavior on y { PropertyAnimation { duration: catcherSpeed } }

        onMovableChanged: {
            catcher.rotation = 0;
        }

        function updateRotation(x, y) {
            catcher.rotation = getRotation(catcher.x + catcher.width/2,
                                           catcher.y + catcher.height/2, x, y);
        }

        function updatePosition(x, y) {
            if (!catcher.movable)
                return;

            catcher.x = x - catcher.width/2;
            catcher.y = y - catcher.height/2;
            catcher.updateRotation(x, y);

            shellPipeTimer.start();
        }

        // Switches catcher source images to make it look like it's biting.
        Timer {
            id: catcherTimer
            repeat: true
            running: true
            interval: 200

            onTriggered: {
                catcher.state = (catcher.state == "closed") ? "opened" : "closed";
            }
        }
    }

    // Warp pipe: this is the pipe the catcher "enters" the map from.
    Image {
        id: warpPipe
        x: board.width/2 - width/2
        y: board.height
        height: 182
        z: 10

        fillMode: Image.PreserveAspectFit
        source: "images/tube.png"

        // Comes out of ground at game beginning with catcher.
        Behavior on y {
            SequentialAnimation {
                PropertyAnimation { easing.type: Easing.InSine; duration: 1000 }
                PauseAnimation { duration: 2000 }
                ScriptAction { script: { catcher.movable = true; } }
                PauseAnimation { duration: 3000 }
                PropertyAnimation { target: warpPipe; property: "y"; to: board.height }
            }
        }
    }

    function checkCollision(a, b) {
        return !((a.y + a.height < b.y)
                 || (a.y > b.y + b.height)
                 || (a.x + a.width < b.x)
                 || (a.x > b.x + b.width));
    }

    function getRandom(minimum, maximum){
        var now = new Date();
        return Math.floor(Math.random(now.getSeconds()) * (maximum - minimum + 1)) + minimum;
    }

    // Returns a rotation amount based on X and Y parameters and touchpoint.
    function getRotation(x, y, pointX, pointY) {
        x -= pointX;
        y -= pointY;
        var d = 0, s = 1;

        if (x <= 0) {
            if (y <= 0) {
                d = 180;
                s = -1;
            } else {
                x = -x;
            }
        } else {
            if (y < 0) {
                d = 180;
                y = -y;
            } else {
                d = 360;
                s = -1;
            }
        }
        return d + s * Math.atan(x/y) * (180/Math.PI);
    }

    function createCoin(x, y, size) {
        coinComp.createObject(board, {"x": x, "y": y, "width": size, "height": size});
    }

    function createCloud(x, y, width) {
        const type = getRandom(1, 3);
        cloudComp.createObject(board, {"x": x, "y": y, "width": width,
                                   "images/source": "cloud_0" + type + ".png"});
    }

    function createShell(x, y) {
        shellComp.createObject(board, {"x": x, "y": y});
    }

    function createShellPipe(x, y, direction) {
        shellPipeComp.createObject(board, {"x": x, "y": y, "direction": direction});

        if (direction === "left") y += 50;
        else if (direction === "right") y += 50;
        else if (direction === "bottom") x += 40;

        shellComp.createObject(board, {"x": x, "y": y, "direction": direction});
    }

    function createBricks() {
        var b1 = brickComp.createObject(board, {"x": getRandom(board.width/7.68, board.width/5.91),
                                            "y": getRandom(board.height/2.4, board.height/1.96)});
        brickComp.createObject(board, {"x": b1.x + b1.width, "y": b1.y});
        brickComp.createObject(board, {"x": b1.x + b1.width*2, "y": b1.y});

        var b2 = brickComp.createObject(board, {"x": getRandom(board.width/2.02, board.width/1.75),
                                            "y": getRandom(board.height/2.8, board.height/2.1)});
        brickComp.createObject(board,{"x": b2.x + b2.width, "y": b2.y});

        var b3 = brickComp.createObject(board, {"x": getRandom(board.width/1.51, board.width/1.37),
                                            "y": getRandom(board.height/2.4, board.height/1.96),
                                            "source": "images/brick-question.png"});
        brickComp.createObject(board, {"x": b3.x + b3.width, "y": b3.y});
        brickComp.createObject(board, {"x": b3.x + b3.width*2, "y": b3.y});
    }

    function gameStart() {
        // At the beginning of the game, put bricks on the screen.
        clearBricks();
        createBricks();

        points = 0;
        livesLost = 0;

        gameOverScore.enabled = false;
        coinCounter.visible = true;
        catcher.visible = true;

        var oldSpeed = catcherSpeed;
        catcherSpeed = 3000;
        catcher.y = board.height - catcher.height - 290;
        warpPipe.y = board.height - backgroundGround.height - warpPipe.height;
        catcherSpeed = oldSpeed;
    }

    function gameOver() {
        shellPipeTimer.stop();

        score = points;

        gameOverScore.enabled = true;
        coinCounter.visible = false;

        catcher.visible = false;
        catcher.movable = false;
        catcher.x = board.width/2 - catcher.width/2;
        catcher.y = board.height + 200;
        warpPipe.y = board.height;
    }

    function destroyObject(object) {
        object.destroy();
    }
}
