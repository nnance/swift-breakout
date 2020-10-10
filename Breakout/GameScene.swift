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

enum ColliderType: UInt32 {
    case Ball = 1
    case Paddle = 2
    case Brick = 4
}

func setCollision(node: SKNode, category: ColliderType, collision: ColliderType) {
    node.physicsBody?.categoryBitMask = category.rawValue
    node.physicsBody?.contactTestBitMask = collision.rawValue
    node.physicsBody?.collisionBitMask = collision.rawValue
}

func paddleFactory(rect: CGRect) -> SKNode {
    let paddle = SKShapeNode(rectOf: paddleSize)
    paddle.position = CGPoint(x: 0, y: -rect.maxY + 150)
    paddle.fillColor = UIColor.white
    
    paddle.physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
    paddle.physicsBody?.isDynamic = false
    paddle.physicsBody?.allowsRotation = false
    paddle.physicsBody?.affectedByGravity = false
    paddle.physicsBody?.friction = 0
    paddle.physicsBody?.restitution = 0
    
    return paddle
}

func ballFactory() -> SKNode {
    let ball = SKShapeNode(circleOfRadius: CGFloat(10))
    ball.name = "ball"
    ball.position = CGPoint(x: -100, y: -100)
    ball.fillColor = UIColor.white
    
    ball.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(10))
    ball.physicsBody?.allowsRotation = false
    ball.physicsBody?.affectedByGravity = false
    ball.physicsBody?.friction = 0
    ball.physicsBody?.restitution = 1
    ball.physicsBody?.linearDamping = 0
    ball.physicsBody?.angularDamping = 0
    
    setCollision(node: ball, category: ColliderType.Ball, collision: ColliderType.Brick)
    
    return ball
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
    
    return [
        paddleFactory(rect: rect),
        ballFactory(),
        scoreFactory(rect: rect)
    ] + rows.flatMap{ $0 }
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
    
    var score = 0
    
    func setupGame() {
        let nodes = sceneFactory(rect: self.frame)
        nodes.forEach{ self.addChild($0) }
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        border.friction = 0
        border.restitution = 1
        
        self.physicsBody = border
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let ball = self.childNode(withName: "ball") as! SKShapeNode
        ball.physicsBody?.applyImpulse(ballSpeed)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Brick.rawValue {
            score += calcScore(node: contact.bodyA.node! as! SKShapeNode)
            contact.bodyA.node!.removeFromParent()
        }
        else if contact.bodyB.categoryBitMask == ColliderType.Brick.rawValue {
            score += calcScore(node: contact.bodyB.node! as! SKShapeNode)
            contact.bodyB.node!.removeFromParent()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let scoreNode = self.childNode(withName: "score") as! SKLabelNode
        scoreNode.text = String(score)
    }
}
