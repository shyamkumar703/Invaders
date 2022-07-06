//
//  GameScene.swift
//  Invaders
//
//  Created by Shyam Kumar on 6/25/22.
//

import TriumphSDK
import CoreMotion
import SpriteKit
import GameplayKit

let localStorageTutorialKey: String = "hasSeenTutorial"

enum TutorialStep {
    case tiltToMove
    case tapToShoot
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let enemy: UInt32 = 1 << 0
    static let bullet: UInt32 = 1 << 1
    static let enemyBullet: UInt32 = 1 << 2
    static let player: UInt32 = 1 << 3
    static let wall: UInt32 = 1 << 4
}

enum EnemyDirection {
    case left
    case right
}

enum EnemyType: String {
    case red
    case yellow
    case green
}

class EnemyRow {
    var nodes: [NodeWithScore]
    var directions: [EnemyDirection]
    var type: EnemyType
    var score: Int
    
    init(nodes: [NodeWithScore] = [], directions: [EnemyDirection] = [], type: EnemyType, score: Int) {
        self.nodes = nodes
        self.directions = directions
        self.type = type
        self.score = score
    }
}

class GameScene: SKScene {
    
    // MARK: - Constants
    let enemyPixelsPerUpdate: CGFloat = 10
    let enemyDescentPerRow: CGFloat = 40
    let enemiesPerRow = 7
    var yMultiplierStart = 0.8
    let playAgainButtonName = "playAgainButton"
    let xStart: CGFloat = 37.5
    let xEnd: CGFloat = 355
    var moveDuration = 0.01
    var enemyBulletTimeToEnd = 0.4
    var numberOfFramesPerEnemyShot = 60
    var isNotch: Bool {
       return (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) > 0
    }
    // MARK: - Nodes
    let player = NodeWithScore(imageNamed: "player")
    var rows = [
        EnemyRow(type: .green, score: 40),
        EnemyRow(type: .red, score: 20),
        EnemyRow(type: .yellow, score: 10),
        EnemyRow(type: .yellow, score: 10)
    ]
    var currUserBullet: SKShapeNode?
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var playAgainButton = SKLabelNode()
    
    // MARK: - Timing
    var pastUpdate: TimeInterval?
    var currentIndex = 0
    
    var timer: Timer?
    
    // MARK: - Score
    var score = 0
    var currentWave = 1
    var isGameOver = false
    
    // MARK: - Device Motion
    let motionManager = CMMotionManager()
    
    // MARK: - Triumph Integration
    var gameDelegate: GameDelegate?
    var rng: TriumphRNG?
    var gameInterface: TriumphGameInterface?
    var mode: GameMode?
    
    // MARK: - Tutorial Mode
    var isInTutorialMode: Bool = false
    var currTutorialStep: TutorialStep?
    
    var tiltInstructionLabel = SKLabelNode(fontNamed: "Public Pixel")
    var tapToShootLabel = SKLabelNode(fontNamed: "Public Pixel")
    
    convenience init(
        size: CGSize,
        delegate: GameDelegate,
        rng: TriumphRNG? = nil,
        gameInterface: TriumphGameInterface? = nil,
        mode: GameMode = .practice,
        shouldShowTutorial: Bool = false
    ) {
        self.init(size: size)
        self.gameDelegate = delegate
        self.rng = rng
        self.gameInterface = gameInterface
        self.mode = mode
        self.isInTutorialMode = shouldShowTutorial
    }
    
    override func didMove(to view: SKView) {
        yMultiplierStart = (0.1 * frame.height + 533.6) / frame.height
        backgroundColor = SKColor.black
        player.position = CGPoint(x: xStart, y: size.height * 0.1)
        addPlayerBitMaskTo(node: player)
        addChild(player)
        timer = Timer.scheduledTimer(
            timeInterval: moveDuration * Double(enemiesPerRow) * Double(rows.count),
            target: self,
            selector: #selector(moveEnemies),
            userInfo: nil,
            repeats: true
        )
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager.startAccelerometerUpdates()
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.wall
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        scoreLabel = SKLabelNode(fontNamed: "Public Pixel")
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 15
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * (isNotch ? 0.9 : 0.95))
        if let gameInterface = gameInterface,
           gameInterface.blitzMode == true {
            scoreLabel.text = "SCORE<0¢>"
        } else {
            scoreLabel.text = "SCORE<\(score)>"
        }
        self.addChild(scoreLabel)
        
        if !isInTutorialMode {
            for (index, row) in rows.enumerated() {
                createNodeArr(addTo: &row.nodes, directionArr: &row.directions, type: row.type, row: index, score: row.score)
            }
        } else {
            showTutorial()
        }
    }
    
    func createNodeArr(addTo: inout [NodeWithScore], directionArr: inout [EnemyDirection], type: EnemyType, row: Int, score: Int) {
        for i in 0..<enemiesPerRow {
            if i == 0 {
                let node = NodeWithScore(imageNamed: type.rawValue)
                node.position = CGPoint(x: xStart, y: size.height * yMultiplierStart - (enemyDescentPerRow * CGFloat(row) * 2))
                addEnemyBitMaskTo(node: node)
                node.scoreOnCollision = score
                addChild(node)
                addTo.append(node)
            } else {
                if let lastNode = addTo.last {
                    let newX = lastNode.position.x + lastNode.size.width + 10
                    let node = NodeWithScore(imageNamed: type.rawValue)
                    node.position = CGPoint(x: newX, y: size.height * yMultiplierStart - (enemyDescentPerRow * CGFloat(row) * 2))
                    addEnemyBitMaskTo(node: node)
                    node.scoreOnCollision = score
                    addChild(node)
                    addTo.append(node)
                }
            }
            directionArr.append(.right)
        }
    }
    
    func addPlayerBitMaskTo(node: NodeWithScore) {
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.enemyBullet | PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = PhysicsCategory.wall
        node.physicsBody?.mass = 0.2
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
    }
    
    func addEnemyBitMaskTo(node: NodeWithScore) {
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        node.physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.enemyBullet | PhysicsCategory.player
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    func addBulletBitMaskTo(node: SKShapeNode) {
        node.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        node.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.enemyBullet
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
        node.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func addEnemyBulletBitMaskTo(node: SKShapeNode) {
        node.physicsBody = SKPhysicsBody(circleOfRadius: 4)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.enemyBullet
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.bullet
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
        node.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func createAndLaunchBullet(startPoint: CGPoint) {
        if let currUserBullet = currUserBullet,
           currUserBullet.parent != nil {
            return
        }
        let node = SKShapeNode(circleOfRadius: 4)
        node.fillColor = .red
        node.strokeColor = .clear
        node.position = startPoint
        addBulletBitMaskTo(node: node)
        addChild(node)
        currUserBullet = node
        node.run(
            SKAction.sequence([
                SKAction.moveTo(y: size.height * yMultiplierStart, duration: 1),
                SKAction.removeFromParent(),
                SKAction.run {
                    self.endTutorial()
                }
            ])
        )
    }
    
    func createAndLaunchEnemyBullet(startPoint: CGPoint) {
        let node = SKShapeNode(circleOfRadius: 4)
        node.fillColor = .green
        node.strokeColor = .clear
        node.position = startPoint
        addEnemyBulletBitMaskTo(node: node)
        addChild(node)
        node.run(SKAction.sequence([SKAction.moveTo(y: size.height * 0.1, duration: 1), SKAction.removeFromParent()]))
    }
    
    func showNewWaveLabel() {
        currentWave += 1
        let waveLabel = SKLabelNode(fontNamed: "Public Pixel")
        waveLabel.fontColor = .white
        waveLabel.fontSize = 30
        waveLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        waveLabel.text = "WAVE<\(currentWave)>"
        self.addChild(waveLabel)
        waveLabel.run(SKAction.sequence([SKAction.wait(forDuration: 2), SKAction.removeFromParent(), SKAction.run(respawnEnemiesAndIncreaseSpeed)]))

    }
    
    func showGameOverLabel() {
        gameOverLabel = SKLabelNode(fontNamed: "Public Pixel")
        gameOverLabel.fontColor = .white
        gameOverLabel.fontSize = 30
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.text = "GAME OVER"
        self.addChild(gameOverLabel)
        if mode == .tournament {
            TriumphSDK.onGameOverInt(with: score, showGameOverViewController: true)
        }
        gameDelegate?.gameFinished()
    }
    
    func showPlayAgainButton() {
        playAgainButton = SKLabelNode(fontNamed: "Public Pixel")
        playAgainButton.fontColor = .white
        playAgainButton.fontSize = 15
        playAgainButton.position = CGPoint(x: gameOverLabel.frame.midX, y: gameOverLabel.frame.minY - 40)
        playAgainButton.text = "PLAY AGAIN"
        playAgainButton.name = playAgainButtonName
        self.addChild(playAgainButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            createAndLaunchBullet(startPoint: CGPoint(x: player.position.x, y: player.position.y + player.size.height / 2))
        } else {
            for touch in touches {
                let location = touch.location(in: self)
                let touchedNode = atPoint(location)
                if touchedNode.name == playAgainButtonName {
                    UIImpactFeedbackGenerator().impactOccurred(intensity: 1)
                    resetAndRestartGame()
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    @objc func moveEnemies() {
        guard !isInTutorialMode else { return }
        for row in rows {
            for currentIndex in 0..<enemiesPerRow {
                let yellow = row.nodes[currentIndex]
                if yellow.isHit { continue }
                if yellow.parent == nil { continue }
                let enemyDirection = row.directions[currentIndex]
                if yellow.position.x + enemyPixelsPerUpdate >= xEnd && enemyDirection == .right {
                    yellow.run(SKAction.moveTo(y: yellow.position.y - enemyDescentPerRow, duration: moveDuration))
                    row.directions[currentIndex] = .left
                } else if yellow.position.x - enemyPixelsPerUpdate <= xStart && enemyDirection == .left {
                    yellow.run(SKAction.moveTo(y: yellow.position.y - enemyDescentPerRow, duration: moveDuration))
                    row.directions[currentIndex] = .right
                } else if enemyDirection == .right {
                    yellow.run(SKAction.moveTo(x: yellow.position.x + enemyPixelsPerUpdate, duration: moveDuration))
                } else {
                    yellow.run(SKAction.moveTo(x: yellow.position.x - enemyPixelsPerUpdate, duration: moveDuration))
                }
                if isInBottomRow(node: yellow) {
                    
                    let randomInt = rng?.getNextInt(minimumInclusive: 1, maximumInclusive: numberOfFramesPerEnemyShot) ?? Int.random(in: 1..<numberOfFramesPerEnemyShot)
                    if randomInt == 2 {
                        createAndLaunchEnemyBullet(startPoint: CGPoint(x: yellow.position.x, y: yellow.position.y - yellow.size.height / 2 - 5))
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let data = motionManager.accelerometerData,
           !isGameOver {
            player.physicsBody?.applyForce(CGVector(dx: 240 * CGFloat(data.acceleration.x), dy: 0))
            if isInTutorialMode && currTutorialStep == .tiltToMove && data.acceleration.x > 0.1 {
                DispatchQueue.main.async {
                    self.showTapToShoot()
                }
            }
        }

    }
    
    // MARK: - Helpers
    func isInBottomRow(node: NodeWithScore) -> Bool {
        let allNodes = rows.flatMap { $0.nodes }.filter { $0.parent != nil }
        for currNode in allNodes {
            if currNode.position.y < node.position.y {
                return false
            }
        }
        return true
    }
    
    func removeAllEnemyBullets() {
        for node in self.children {
            if let bitMask = node.physicsBody?.categoryBitMask,
               bitMask & PhysicsCategory.enemyBullet != 0 {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: - Handle collision
    func bulletDidHitEnemy(bullet: SKShapeNode, enemy: NodeWithScore) {
        guard !isInTutorialMode else { return }
        enemy.isHit = true
        bullet.removeFromParent()
        enemy.run(
            SKAction.sequence(
                [
                    SKAction.scale(by: 0, duration: 0.1),
                    SKAction.removeFromParent(),
                    SKAction.run { [self] in
                        if checkForRoundCompletion() {
                            showNewWaveLabel()
                        }
                    }
                ]))
        score += enemy.scoreOnCollision
        if let gameInterface = gameInterface,
           gameInterface.blitzMode == true {
            scoreLabel.text = "SCORE<\(TriumphGameInterface.getBlitzPayoutForScoreInt(totalScore: score))>"
        } else {
            scoreLabel.text = "SCORE<\(score)>"
        }
    }
    
    func enemyBulletDidHitPlayer(bullet: SKShapeNode? = nil, player: NodeWithScore) {
        if !checkForRoundCompletion() {
            removeAllEnemyBullets()
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            isGameOver = true
            if let bullet = bullet { bullet.removeFromParent() }
            timer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                player.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.1),
                    SKAction.repeat(
                        SKAction.sequence(
                            [
                                SKAction.run(togglePlayerIsHidden),
                                SKAction.wait(forDuration: 0.2)
                            ]
                        ),
                        count: 9
                    ),
                    SKAction.wait(forDuration: 0.3),
                    SKAction.run(removeAllEnemies),
                    SKAction.removeFromParent()
                ]))
            }
        }
    }
    
    func togglePlayerIsHidden() {
        player.isHidden.toggle()
    }
    
    func removeAllEnemies() {
        for row in rows {
            for node in row.nodes {
                if node.parent != nil {
                    node.removeFromParent()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.removeAllEnemies()
                    }
                    return
                }
            }
        }
        showGameOverLabel()
    }
    
    // MARK: - Respawn enemies (on round conclusion)
    func respawnEnemiesAndIncreaseSpeed() {
        for row in rows {
            row.directions = []
            row.nodes = []
        }
        
        for (index, row) in rows.enumerated() {
            createNodeArr(addTo: &row.nodes, directionArr: &row.directions, type: row.type, row: index, score: row.score)
        }
        
        if moveDuration > 0.004 { moveDuration -= 0.002 }
        if enemyBulletTimeToEnd > 0.4 { enemyBulletTimeToEnd -= 0.2 }
        if numberOfFramesPerEnemyShot > 4 { numberOfFramesPerEnemyShot -= 2 }
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: moveDuration * Double(enemiesPerRow) * Double(rows.count),
            target: self,
            selector: #selector(moveEnemies),
            userInfo: nil,
            repeats: true
        )
    }
    
    func resetAndRestartGame() {
        gameOverLabel.removeFromParent()
        playAgainButton.removeFromParent()
        // Reset constants
        moveDuration = 0.01
        enemyBulletTimeToEnd = 0.4
        numberOfFramesPerEnemyShot = 60
        currentWave = 1
        score = 0
        isGameOver = false
        // Reset nodes
        for row in rows {
            row.directions = []
            row.nodes = []
        }
        
        for (index, row) in rows.enumerated() {
            createNodeArr(addTo: &row.nodes, directionArr: &row.directions, type: row.type, row: index, score: row.score)
        }
        
        player.position = CGPoint(x: xStart, y: size.height * 0.1)
        player.isHidden = false
        addChild(player)
        // Reset score label
        scoreLabel.text = "SCORE<\(score)>"
        // Reset timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: moveDuration * Double(enemiesPerRow) * Double(rows.count),
            target: self,
            selector: #selector(moveEnemies),
            userInfo: nil,
            repeats: true
        )
    }
    
    func checkForRoundCompletion() -> Bool {
        for row in rows {
            for node in row.nodes {
                if node.parent != nil {
                    return false
                }
            }
        }
        return true
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.bullet != 0)) {
            if let enemy = firstBody.node as? NodeWithScore,
               let bullet = secondBody.node as? SKShapeNode {
                bulletDidHitEnemy(bullet: bullet, enemy: enemy)
                UIImpactFeedbackGenerator().impactOccurred(intensity: 1)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.enemyBullet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.player != 0)) {
            if let enemyBullet = firstBody.node as? SKShapeNode,
               let player = secondBody.node as? NodeWithScore {
                enemyBulletDidHitPlayer(bullet: enemyBullet, player: player)
                UIImpactFeedbackGenerator().impactOccurred(intensity: 0.5)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.enemyBullet != 0)) {
            if let enemyBullet = secondBody.node as? SKShapeNode {
                enemyBullet.removeFromParent()
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.bullet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.enemyBullet != 0)) {
            if let bullet = firstBody.node as? SKShapeNode,
               let enemyBullet = secondBody.node as? SKShapeNode {
                bullet.removeFromParent()
                enemyBullet.removeFromParent()
                UIImpactFeedbackGenerator().impactOccurred(intensity: 0.5)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.player != 0)) {
            if let player = secondBody.node as? NodeWithScore {
                UIImpactFeedbackGenerator().impactOccurred(intensity: 1)
                enemyBulletDidHitPlayer(player: player)
            }
        }
    }
}

extension GameScene {
    func showTutorial() {
        showTiltToMove()
    }
    
    func showTiltToMove() {
        tiltInstructionLabel.text = "TILT TO MOVE"
        tiltInstructionLabel.fontSize = 20
        tiltInstructionLabel.fontColor = .white
        tiltInstructionLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tiltInstructionLabel)
        currTutorialStep = .tiltToMove
    }
    
    func showTapToShoot() {
        guard tapToShootLabel.parent == nil else { return }
        tiltInstructionLabel.isHidden = true
        tiltInstructionLabel.removeFromParent()
        tapToShootLabel.text = "TAP TO SHOOT"
        tapToShootLabel.fontSize = 20
        tapToShootLabel.fontColor = .white
        tapToShootLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tapToShootLabel)
        currTutorialStep = .tapToShoot
    }
    
    func endTutorial() {
        DispatchQueue.main.async { [self] in
            if isInTutorialMode {
                tapToShootLabel.removeFromParent()
                for (index, row) in rows.enumerated() {
                    createNodeArr(addTo: &row.nodes, directionArr: &row.directions, type: row.type, row: index, score: row.score)
                }
                isInTutorialMode = false
                UserDefaults.standard.set(true, forKey: localStorageTutorialKey)
            }
        }
    }
}


class NodeWithScore: SKSpriteNode {
    var scoreOnCollision: Int = 0
    var isHit: Bool = false
}
