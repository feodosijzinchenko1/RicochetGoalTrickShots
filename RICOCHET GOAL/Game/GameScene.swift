import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    var onShoot: (() -> Void)?
    var onGoal: ((Int) -> Void)?
    var onMiss: (() -> Void)?
    var onRicochet: ((Int) -> Void)?

    private enum Category {
        static let ball: UInt32 = 0x1 << 0
        static let wall: UInt32 = 0x1 << 1
        static let goal: UInt32 = 0x1 << 2
        static let keeper: UInt32 = 0x1 << 3
        static let booster: UInt32 = 0x1 << 4
    }

    private enum ShotState {
        case ready
        case live
        case finished
    }

    private var level: LevelConfig = GameCatalog.levels[0]
    private var skin: ShopSkin = GameCatalog.skins[0]

    private let ball = SKShapeNode(circleOfRadius: 13)
    private var keeper = SKShapeNode()
    private let aimLine = SKShapeNode()
    private var goalCenterY: CGFloat = 0
    private var goalGap: CGFloat = 0

    private var state: ShotState = .ready
    private var ricochetCount = 0
    private var shotElapsed: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0
    private var keeperCommitted = false
    private var keeperPhase: CGFloat = 0
    private var stuckTime: TimeInterval = 0

    private let baseSpeed: CGFloat = 560
    private let maxSpeed: CGFloat = 1000
    private let maxShotDuration: TimeInterval = 6.5
    private let inset: CGFloat = 8

    func configure(level: LevelConfig, skin: ShopSkin) {
        self.level = level
        self.skin = skin
    }

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor(hex: level.palette.field)
        buildField()
        buildGoal()
        buildBall()
        buildKeeper()
        buildBuffers()
        buildBoosters()
        buildAimLine()
        resetBall()
    }

    private var playRect: CGRect {
        return CGRect(x: inset, y: inset, width: size.width - inset * 2, height: size.height - inset * 2)
    }

    private func buildField() {
        let rect = playRect
        goalGap = rect.height * 0.34
        goalCenterY = rect.midY

        let top = makeWall(from: CGPoint(x: rect.minX, y: rect.maxY), to: CGPoint(x: rect.maxX, y: rect.maxY))
        let bottom = makeWall(from: CGPoint(x: rect.minX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.minY))
        let left = makeWall(from: CGPoint(x: rect.minX, y: rect.minY), to: CGPoint(x: rect.minX, y: rect.maxY))
        let rightLower = makeWall(from: CGPoint(x: rect.maxX, y: rect.minY), to: CGPoint(x: rect.maxX, y: goalCenterY - goalGap / 2))
        let rightUpper = makeWall(from: CGPoint(x: rect.maxX, y: goalCenterY + goalGap / 2), to: CGPoint(x: rect.maxX, y: rect.maxY))
        [top, bottom, left, rightLower, rightUpper].forEach { addChild($0) }

        let border = SKShapeNode(rect: rect, cornerRadius: 12)
        border.strokeColor = UIColor(hex: level.palette.border)
        border.lineWidth = 4
        border.fillColor = .clear
        border.zPosition = 1
        addChild(border)

        let centerLine = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        centerLine.path = path
        centerLine.strokeColor = UIColor(hex: level.palette.border).withAlphaComponent(0.35)
        centerLine.lineWidth = 2
        addChild(centerLine)
    }

    private func makeWall(from: CGPoint, to: CGPoint) -> SKNode {
        let node = SKNode()
        let body = SKPhysicsBody(edgeFrom: from, to: to)
        body.categoryBitMask = Category.wall
        body.contactTestBitMask = Category.ball
        body.collisionBitMask = Category.ball
        body.restitution = 1
        body.friction = 0
        node.physicsBody = body
        return node
    }

    private func buildGoal() {
        let rect = playRect
        let goalNode = SKShapeNode(rectOf: CGSize(width: 10, height: goalGap))
        goalNode.position = CGPoint(x: rect.maxX - 2, y: goalCenterY)
        goalNode.fillColor = UIColor(hex: level.palette.goal).withAlphaComponent(0.18)
        goalNode.strokeColor = UIColor(hex: level.palette.goal)
        goalNode.lineWidth = 2
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 6, height: goalGap - 6))
        body.isDynamic = false
        body.categoryBitMask = Category.goal
        body.contactTestBitMask = Category.ball
        body.collisionBitMask = 0
        goalNode.physicsBody = body
        addChild(goalNode)

        let postTop = SKShapeNode(circleOfRadius: 5)
        postTop.position = CGPoint(x: rect.maxX, y: goalCenterY + goalGap / 2)
        postTop.fillColor = UIColor(hex: level.palette.goal)
        postTop.strokeColor = .clear
        addChild(postTop)
        let postBottom = SKShapeNode(circleOfRadius: 5)
        postBottom.position = CGPoint(x: rect.maxX, y: goalCenterY - goalGap / 2)
        postBottom.fillColor = UIColor(hex: level.palette.goal)
        postBottom.strokeColor = .clear
        addChild(postBottom)
    }

    private func buildBall() {
        ball.fillColor = UIColor(hex: skin.ballHex)
        ball.strokeColor = UIColor(hex: skin.trailHex)
        ball.lineWidth = 2
        ball.zPosition = 10
        let body = SKPhysicsBody(circleOfRadius: 13)
        body.categoryBitMask = Category.ball
        body.contactTestBitMask = Category.wall | Category.goal | Category.keeper | Category.booster
        body.collisionBitMask = Category.wall | Category.keeper
        body.restitution = 1
        body.friction = 0
        body.linearDamping = 0
        body.angularDamping = 0
        body.allowsRotation = true
        body.usesPreciseCollisionDetection = true
        ball.physicsBody = body
        addChild(ball)
    }

    private func buildKeeper() {
        let rect = playRect
        let height = max(54, goalGap * 0.32)
        keeper = SKShapeNode(rectOf: CGSize(width: 16, height: height), cornerRadius: 6)
        keeper.fillColor = UIColor(hex: level.palette.accent)
        keeper.strokeColor = .white
        keeper.lineWidth = 1.5
        keeper.zPosition = 8
        keeper.position = CGPoint(x: rect.maxX - 30, y: goalCenterY)
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: height))
        body.isDynamic = false
        body.categoryBitMask = Category.keeper
        body.contactTestBitMask = Category.ball
        body.collisionBitMask = Category.ball
        body.restitution = 1
        body.friction = 0
        keeper.physicsBody = body
        addChild(keeper)
    }

    private func buildBuffers() {
        let rect = playRect
        guard level.bufferCount > 0 else { return }
        for index in 0..<level.bufferCount {
            let isVertical = index % 2 == 0
            let bufferSize = CGSize(width: isVertical ? 18 : 80, height: isVertical ? 80 : 18)
            let buffer = SKShapeNode(rectOf: bufferSize, cornerRadius: 6)
            buffer.fillColor = UIColor(hex: level.palette.border)
            buffer.strokeColor = UIColor(hex: level.palette.accent)
            buffer.lineWidth = 1.5
            buffer.zPosition = 5

            let fraction = CGFloat(index + 1) / CGFloat(level.bufferCount + 1)
            let startX = rect.minX + rect.width * (0.32 + 0.4 * fraction)
            let startY = rect.minY + rect.height * fraction
            buffer.position = CGPoint(x: startX, y: startY)

            let body = SKPhysicsBody(rectangleOf: bufferSize)
            body.isDynamic = false
            body.categoryBitMask = Category.wall
            body.contactTestBitMask = Category.ball
            body.collisionBitMask = Category.ball
            body.restitution = 1
            body.friction = 0
            buffer.physicsBody = body
            addChild(buffer)

            let travel = rect.height * 0.28
            let duration = max(1.2, travel / CGFloat(level.bufferSpeed))
            let move: SKAction
            if isVertical {
                move = SKAction.sequence([
                    SKAction.moveBy(x: 0, y: travel, duration: duration),
                    SKAction.moveBy(x: 0, y: -travel * 2, duration: duration * 2),
                    SKAction.moveBy(x: 0, y: travel, duration: duration)
                ])
            } else {
                move = SKAction.sequence([
                    SKAction.moveBy(x: travel * 0.6, y: 0, duration: duration),
                    SKAction.moveBy(x: -travel * 1.2, y: 0, duration: duration * 2),
                    SKAction.moveBy(x: travel * 0.6, y: 0, duration: duration)
                ])
            }
            buffer.run(SKAction.repeatForever(move))
        }
    }

    private func buildBoosters() {
        let rect = playRect
        guard level.boosterCount > 0 else { return }
        for index in 0..<level.boosterCount {
            let booster = SKShapeNode(circleOfRadius: 20)
            booster.fillColor = UIColor(hex: level.palette.accent).withAlphaComponent(0.25)
            booster.strokeColor = UIColor(hex: level.palette.accent)
            booster.lineWidth = 2
            booster.zPosition = 4
            let fraction = CGFloat(index + 1) / CGFloat(level.boosterCount + 1)
            booster.position = CGPoint(x: rect.midX, y: rect.minY + rect.height * fraction)

            let body = SKPhysicsBody(circleOfRadius: 20)
            body.isDynamic = false
            body.categoryBitMask = Category.booster
            body.contactTestBitMask = Category.ball
            body.collisionBitMask = 0
            booster.physicsBody = body
            booster.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.6),
                SKAction.scale(to: 0.9, duration: 0.6)
            ])))
            addChild(booster)
        }
    }

    private func buildAimLine() {
        aimLine.strokeColor = UIColor(hex: level.palette.accent).withAlphaComponent(0.8)
        aimLine.lineWidth = 3
        aimLine.lineCap = .round
        aimLine.zPosition = 9
        aimLine.isHidden = true
        addChild(aimLine)
    }

    private func resetBall() {
        let rect = playRect
        ball.physicsBody?.velocity = .zero
        ball.physicsBody?.angularVelocity = 0
        ball.position = CGPoint(x: rect.minX + rect.width * 0.16, y: rect.midY)
        state = .ready
        ricochetCount = 0
        shotElapsed = 0
        stuckTime = 0
        keeperCommitted = false
        onRicochet?(0)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state == .ready, let touch = touches.first else { return }
        updateAim(to: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state == .ready, let touch = touches.first else { return }
        updateAim(to: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state == .ready, let touch = touches.first else {
            aimLine.isHidden = true
            return
        }
        shoot(toward: touch.location(in: self))
        aimLine.isHidden = true
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        aimLine.isHidden = true
    }

    private func updateAim(to point: CGPoint) {
        let path = CGMutablePath()
        path.move(to: ball.position)
        path.addLine(to: point)
        aimLine.path = path
        aimLine.isHidden = false
    }

    private func shoot(toward point: CGPoint) {
        let dx = point.x - ball.position.x
        let dy = point.y - ball.position.y
        let length = max(1, sqrt(dx * dx + dy * dy))
        let velocity = CGVector(dx: dx / length * baseSpeed, dy: dy / length * baseSpeed)
        ball.physicsBody?.velocity = velocity
        state = .live
        ricochetCount = 0
        shotElapsed = 0
        stuckTime = 0
        keeperCommitted = false
        onShoot?()
        onRicochet?(0)
    }

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdate == 0 ? 0 : currentTime - lastUpdate
        lastUpdate = currentTime

        updateKeeper(delta: delta)

        guard state == .live, let body = ball.physicsBody else { return }
        shotElapsed += delta

        var velocity = body.velocity
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        if speed > maxSpeed {
            let scale = maxSpeed / speed
            velocity = CGVector(dx: velocity.dx * scale, dy: velocity.dy * scale)
            body.velocity = velocity
        }

        if speed < 40 {
            stuckTime += delta
            if stuckTime > 0.6 { finishMiss() }
        } else {
            stuckTime = 0
        }

        if shotElapsed > maxShotDuration {
            finishMiss()
        }
    }

    private func updateKeeper(delta: TimeInterval) {
        let rect = playRect
        let topLimit = goalCenterY + goalGap / 2 - keeper.frame.height / 2
        let bottomLimit = goalCenterY - goalGap / 2 + keeper.frame.height / 2

        if state == .live {
            let zoneX = rect.maxX - CGFloat(level.keeperRange)
            if ball.position.x >= zoneX && (ball.physicsBody?.velocity.dx ?? 0) > 0 && !keeperCommitted {
                keeperCommitted = true
                let target = min(max(ball.position.y, bottomLimit), topLimit)
                keeper.removeAllActions()
                keeper.run(SKAction.moveTo(y: target, duration: level.keeperReaction))
            } else if !keeperCommitted {
                patrolKeeper(delta: delta, top: topLimit, bottom: bottomLimit)
            }
        } else {
            patrolKeeper(delta: delta, top: topLimit, bottom: bottomLimit)
        }
    }

    private func patrolKeeper(delta: TimeInterval, top: CGFloat, bottom: CGFloat) {
        keeperPhase += CGFloat(delta) * 1.6
        let center = (top + bottom) / 2
        let amplitude = (top - bottom) / 2
        keeper.position.y = center + sin(keeperPhase) * amplitude
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision & Category.goal != 0 {
            finishGoal()
            return
        }
        if collision & Category.keeper != 0 {
            finishSave()
            return
        }
        if collision & Category.booster != 0 {
            applyBoost()
            return
        }
        if collision & Category.wall != 0, state == .live {
            ricochetCount += 1
            onRicochet?(ricochetCount)
            flashBall()
        }
    }

    private func applyBoost() {
        guard let body = ball.physicsBody else { return }
        let velocity = body.velocity
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        guard speed > 1 else { return }
        let target = min(maxSpeed, speed * 1.4)
        let scale = target / speed
        body.velocity = CGVector(dx: velocity.dx * scale, dy: velocity.dy * scale)
    }

    private func flashBall() {
        ball.run(SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.08)
        ]))
    }

    private func finishGoal() {
        guard state == .live else { return }
        state = .finished
        let scored = ricochetCount
        celebrateGoal()
        onGoal?(scored)
        run(SKAction.sequence([SKAction.wait(forDuration: 0.9), SKAction.run { [weak self] in self?.resetBall() }]))
    }

    private func finishSave() {
        guard state == .live else { return }
        state = .finished
        keeper.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.12)
        ]))
        onMiss?()
        run(SKAction.sequence([SKAction.wait(forDuration: 0.7), SKAction.run { [weak self] in self?.resetBall() }]))
    }

    private func finishMiss() {
        guard state == .live else { return }
        state = .finished
        onMiss?()
        resetBall()
    }

    private func celebrateGoal() {
        let rect = playRect
        for _ in 0..<14 {
            let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            spark.fillColor = UIColor(hex: level.palette.accent)
            spark.strokeColor = .clear
            spark.position = CGPoint(x: rect.maxX - 20, y: goalCenterY)
            spark.zPosition = 20
            addChild(spark)
            let dx = CGFloat.random(in: -90...30)
            let dy = CGFloat.random(in: -90...90)
            spark.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: dx, y: dy, duration: 0.6),
                    SKAction.fadeOut(withDuration: 0.6)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
}
