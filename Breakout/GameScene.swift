//
//  GameScene.swift
//  Breakout
//
//  Created by Nick Nance on 10/7/20.
//  Copyright © 2020 Nick Nance. All rights reserved.
//

import SpriteKit
import GameplayKit

// game constants to easily adjust game settings
let paddleSize = CGSize(width: 80, height: 20)
let brickSize = CGSize(width: 54, height: 20)
let brickSpacing = 4
let wallOffset = 200
let ballSpeed = CGVector(dx: 10, dy: 10)
let ballStart = CGPoint(x: -100, y: -100)

enum ColliderType: UInt32 {
    case Ball = 1
    case Paddle = 2
    case Brick = 4
    case Gap = 8
}

func setCollision(node: SKNode, category: ColliderType, collision: ColliderType) {
    node.physicsBody?.categoryBitMask = category.rawValue
    node.physicsBody?.contactTestBitMask = collision.rawValue
    node.physicsBody?.collisionBitMask = collision.rawValue
}

func paddleFactory(rect: CGRect) -> SKNode {
    let physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
    physicsBody.isDynamic = false
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    physicsBody.friction = 0
    physicsBody.restitution = 0
    
    let paddle = SKShapeNode(rectOf: paddleSize)
    paddle.name = "paddle"
    paddle.position = CGPoint(x: 0, y: -rect.maxY + 150)
    paddle.fillColor = UIColor.white
    paddle.physicsBody = physicsBody
    
    return paddle
}

func ballFactory() -> SKNode {
    let physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(10))
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    physicsBody.friction = 0
    physicsBody.restitution = 1
    physicsBody.linearDamping = 0
    physicsBody.angularDamping = 0
    
    let ball = SKShapeNode(circleOfRadius: CGFloat(10))
    ball.name = "ball"
    ball.position = ballStart
    ball.fillColor = UIColor.white
    ball.physicsBody = physicsBody
    
    setCollision(node: ball, category: ColliderType.Ball, collision: ColliderType.Brick)
    
    return ball
}

func wallFactory(rect: CGRect) -> SKShapeNode {
    let physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
    physicsBody.isDynamic = false
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    physicsBody.friction = 0
    physicsBody.restitution = 1
    physicsBody.linearDamping = 0
    physicsBody.angularDamping = 0

    let wall = SKShapeNode(rect: rect)
    wall.physicsBody = physicsBody

    return wall
}

func leftWallFactory(rect: CGRect) -> SKShapeNode {
    let rect = CGRect(x: rect.minX, y: rect.maxY, width: 1, height: rect.minY * 2)
    return wallFactory(rect: rect)
}

func rightWallFactory(rect: CGRect) -> SKShapeNode {
    let rect = CGRect(x: rect.maxX, y: rect.maxY, width: 1, height: rect.minY * 2)
    return wallFactory(rect: rect)
}

func topWallFactory(rect: CGRect) -> SKShapeNode {
    let rect = CGRect(x: rect.minX, y: rect.maxY, width: rect.maxX * 2, height: 1)
    return wallFactory(rect: rect)
}

func bottomWallFactory(rect: CGRect) -> SKNode {
    let point = CGPoint(x: rect.minX, y: rect.minY)
    let size = CGSize(width: rect.maxX * 2, height: 1)
    
    let physicsBody = SKPhysicsBody(rectangleOf: size)
    physicsBody.isDynamic = false
    physicsBody.categoryBitMask = ColliderType.Gap.rawValue
    physicsBody.contactTestBitMask = ColliderType.Ball.rawValue
    physicsBody.collisionBitMask = ColliderType.Ball.rawValue
    
    let wall = SKNode()
    wall.position = point
    wall.physicsBody = physicsBody

    return wall
}

func brickFactory(pos: CGPoint, color: UIColor) -> SKNode {
    let brick = SKShapeNode(rectOf: brickSize)
    brick.position = pos
    brick.fillColor = color
    brick.strokeColor = color
    
    brick.physicsBody = SKPhysicsBody(rectangleOf: brickSize)
    brick.physicsBody?.isDynamic = false
    brick.physicsBody?.allowsRotation = false
    brick.physicsBody?.affectedByGravity = false
    brick.physicsBody?.friction = 0
    brick.physicsBody?.restitution = 0

    setCollision(node: brick, category: ColliderType.Brick, collision: ColliderType.Ball)
    
    return brick
}

//TODO: adjust brick width based on device width
func rowFactory(rect: CGRect, row: Int, color: UIColor) -> [SKNode] {
    var bricks: [SKNode] = []
    
    let brickWidth = Int(brickSize.width)
    let brickHeight = Int(brickSize.height)
    
    for idx in 0...12 {
        let x = -rect.maxX + CGFloat(brickWidth * idx + brickSpacing * idx + brickWidth / 2)
        let y = rect.maxY - CGFloat(brickHeight * row + brickSpacing * row + wallOffset)
        bricks.append(brickFactory(pos: CGPoint(x: x, y: y), color: color))
    }

    return bricks
}

func scoreFactory(rect: CGRect) -> SKLabelNode {
    let scoreLabel = SKLabelNode()
    scoreLabel.name = "score"
    scoreLabel.fontName = "Helvetica"
    scoreLabel.fontSize = 60
    scoreLabel.text = "0"
    scoreLabel.position = CGPoint(x: rect.midX, y: rect.height / 2 - 100)
    return scoreLabel
}

func sceneFactory(rect: CGRect) -> [SKNode] {
    let rows = [
        rowFactory(rect: rect, row: 1, color: UIColor.red),
        rowFactory(rect: rect, row: 2, color: UIColor.red),
        rowFactory(rect: rect, row: 3, color: UIColor.orange),
        rowFactory(rect: rect, row: 4, color: UIColor.orange),
        rowFactory(rect: rect, row: 5, color: UIColor.green),
        rowFactory(rect: rect, row: 6, color: UIColor.green),
        rowFactory(rect: rect, row: 7, color: UIColor.yellow),
        rowFactory(rect: rect, row: 8, color: UIColor.yellow)
    ]
    
    let nodes = [
        leftWallFactory(rect: rect),
        rightWallFactory(rect: rect),
        topWallFactory(rect: rect),
        bottomWallFactory(rect: rect),
        paddleFactory(rect: rect),
        ballFactory(),
        scoreFactory(rect: rect)
    ]

    return nodes + rows.flatMap{ $0 }
}

func messageFactory(rect: CGRect, text: String) -> SKNode {
    let label = SKLabelNode()
    label.name = "message"
    label.fontName = "Helvetica"
    label.fontSize = 30
    label.text = text
    label.position = CGPoint(x: rect.midX, y: rect.midY)
    return label
}

func turnOverFactory(rect: CGRect) -> SKNode {
    return messageFactory(rect: rect, text: "Turn ended! Tap to try again.")
}

func gameOverFactory(rect: CGRect) -> SKNode {
    return messageFactory(rect: rect, text: "Game Over! Tap to play again.")
}

func calcScore(node: SKShapeNode) -> Int {
    return node.fillColor == UIColor.yellow
        ? 1
        : node.fillColor == UIColor.green
        ? 3
        : node.fillColor == UIColor.orange
        ? 5
        : 7  // red
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var started = false
    var turnsLeft = 3
    var score = 0
    var gameOver = false
    
    func setupGame() {
        self.turnsLeft = 3
        self.score = 0
        self.gameOver = false
        
        let nodes = sceneFactory(rect: self.frame)
        nodes.forEach{ self.addChild($0) }
    }
    
    func startGame() {
        let ball = self.childNode(withName: "ball")
        ball?.position = ballStart
        ball?.physicsBody?.applyImpulse(ballSpeed)
        
        let label = self.childNode(withName: "message")
        label?.removeFromParent()
        
        self.started = true
    }
    
    func resetGame() {
        self.removeAllChildren()
        setupGame()
        startGame()
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        let paddle = self.childNode(withName: "paddle")
        paddle?.position.x = pos.x
    }
    
    func moveWithTouches(touches: Set<UITouch>) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupGame()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

        let brick = contact.bodyA.categoryBitMask == ColliderType.Brick.rawValue
            ? contact.bodyA.node! as? SKShapeNode
            : contact.bodyB.categoryBitMask == ColliderType.Brick.rawValue
            ? contact.bodyB.node! as? SKShapeNode
            : nil
        
        if (brick != nil) {
            score += calcScore(node: brick!)
            brick?.removeFromParent()
        }

        let gap = contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue
            ? contact.bodyA.node
            : contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue
            ? contact.bodyB.node
            : nil
        
        if (gap != nil) {
            self.started = false

            // stop the ball
            let ball = self.childNode(withName: "ball")
            ball?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            self.gameOver = turnsLeft == 1
            
            let label = self.gameOver ? gameOverFactory(rect: self.frame) : turnOverFactory(rect: self.frame)
            self.addChild(label)

            self.turnsLeft -= 1
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!self.gameOver) {
            if (!self.started) {
                startGame()
            } else {
                moveWithTouches(touches: touches)
            }
        } else {
            resetGame()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveWithTouches(touches: touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let scoreNode = self.childNode(withName: "score") as! SKLabelNode
        scoreNode.text = String(score)
    }
}
