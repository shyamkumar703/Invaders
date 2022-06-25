//
//  GameScene.swift
//  Invaders

import SpriteKit
import GameplayKit

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
    var nodes: [SKSpriteNode]
    var directions: [EnemyDirection]
    var type: EnemyType
    
    init(nodes: [SKSpriteNode] = [], directions: [EnemyDirection] = [], type: EnemyType) {
        self.nodes = nodes
        self.directions = directions
        self.type = type
    }
}

class GameScene: SKScene {
    
    // MARK: - Constants
    let enemyPixelsPerUpdate: CGFloat = 10
    let enemyDescentPerRow: CGFloat = 40
    let enemiesPerRow = 5
    let moveDuration = 0.01
    let yMultiplierStart = 0.8
    
    // MARK: - Nodes
    let player = SKSpriteNode(imageNamed: "player")
    var rows = [
        EnemyRow(type: .green),
        EnemyRow(type: .red),
        EnemyRow(type: .yellow),
        EnemyRow(type: .yellow)
    ]
    
    // MARK: - Timing
    var pastUpdate: TimeInterval?
    var currentIndex = 0
    
    var timer: Timer?
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.1)
        for (index, row) in rows.enumerated() {
            createNodeArr(addTo: &row.nodes, directionArr: &row.directions, type: row.type, row: index)
        }
        addChild(player)
        timer = Timer.scheduledTimer(
            timeInterval: moveDuration * Double(enemiesPerRow) * Double(rows.count),
            target: self,
            selector: #selector(moveEnemies),
            userInfo: nil,
            repeats: true
        )
    }
    
    func createNodeArr(addTo: inout [SKSpriteNode], directionArr: inout [EnemyDirection], type: EnemyType, row: Int) {
        for i in 0..<enemiesPerRow {
            if i == 0 {
                let node = SKSpriteNode(imageNamed: type.rawValue)
                node.position = CGPoint(x: size.width * 0.1, y: size.height * yMultiplierStart - (enemyDescentPerRow * CGFloat(row) * 2))
                addChild(node)
                addTo.append(node)
            } else {
                if let lastNode = addTo.last {
                    let newX = lastNode.position.x + lastNode.size.width + 10
                    let node = SKSpriteNode(imageNamed: type.rawValue)
                    node.position = CGPoint(x: newX, y: size.height * yMultiplierStart - (enemyDescentPerRow * CGFloat(row) * 2))
                    addChild(node)
                    addTo.append(node)
                }
            }
            directionArr.append(.right)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    @objc func moveEnemies() {
        for row in rows {
            for currentIndex in 0..<enemiesPerRow {
                let yellow = row.nodes[currentIndex]
                let enemyDirection = row.directions[currentIndex]
                if yellow.position.x + enemyPixelsPerUpdate >= size.width - 20 && enemyDirection == .right {
                    yellow.run(SKAction.moveTo(y: yellow.position.y - enemyDescentPerRow, duration: moveDuration))
                    row.directions[currentIndex] = .left
                } else if yellow.position.x - enemyPixelsPerUpdate <= 20 && enemyDirection == .left {
                    yellow.run(SKAction.moveTo(y: yellow.position.y - enemyDescentPerRow, duration: moveDuration))
                    row.directions[currentIndex] = .right
                } else if enemyDirection == .right {
                    yellow.run(SKAction.moveTo(x: yellow.position.x + enemyPixelsPerUpdate, duration: moveDuration))
                } else {
                    yellow.run(SKAction.moveTo(x: yellow.position.x - enemyPixelsPerUpdate, duration: moveDuration))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
}
