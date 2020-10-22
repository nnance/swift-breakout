//
//  GameScene.swift
//  Breakout
//
//  Created by Nick Nance on 10/7/20.
//  Copyright © 2020 Nick Nance. All rights reserved.
//

/*
 Requirements:
 
* 1) Breakout begins with eight rows of bricks, with each two rows a different color.
* 2) The color order from the bottom up is yellow, green, orange and red.
* 3) There is a single ball
* 4) Bricks are elminated when the ball hits them
* 5) If the player's paddle misses the ball's rebound, they will lose a turn.
* 6) The player has a total of three turns
 7) To clear two screens of bricks
* 8) Yellow bricks earn one point each, green bricks earn three points, orange bricks earn five points and the top-level red bricks score seven points each.
* 9) The paddle shrinks to one-half its size after the ball has broken through the red row and hit the upper wall.
 * 10) Ball speed increases at specific intervals: after four hits, after twelve hits, and after making contact with the orange and red rows.
 
 */

import SpriteKit
import GameplayKit

// game constants to easily adjust game settings
let showPhysics = false
let maxTurns = 3
enum scoring: Int {
    case yellow = 1
    case green = 3
    case orange = 5
    case red = 7
}
let ballSize = CGFloat(8)
let paddleSize = CGSize(width: 60, height: 20)
let brickSize = CGSize(width: 45, height: 20)
let brickSpacing = 4
let wallOffset = 200
let ballStart = CGPoint(x: -100, y: -100)
let ballSpeed = 3
let ballSpeedInc = 100

struct GameState {
    var started = false
    var gameOver = false
    var level = 1
    var turnsLeft = maxTurns
    var score = 0
    var hitCount = 0
    var hasHitOrange = false
    var hasHitRed = false
    var hasHitTop = false
    var nodesToRemove = [SKNode]()
    var nodesToAdd = [SKNode]()
}

func setCollision(node: SKNode, category: ColliderType, collision: ColliderType) {
    node.physicsBody?.categoryBitMask = category.rawValue
    node.physicsBody?.contactTestBitMask = collision.rawValue
    node.physicsBody?.collisionBitMask = collision.rawValue
}

func paddleFactory(pos: CGPoint, paddleSize: CGSize) -> SKNode {
    let physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
    physicsBody.isDynamic = false
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    physicsBody.friction = 0
    physicsBody.restitution = 0
    
    let paddle = SKShapeNode(rectOf: paddleSize)
    paddle.name = "paddle"
    paddle.position = pos
    paddle.fillColor = UIColor.white
    paddle.physicsBody = physicsBody
    
    return paddle
}

func paddleFactory(_ rect: CGRect) -> SKNode {
    return paddleFactory(pos: CGPoint(x: 0, y: -rect.maxY + 150), paddleSize: paddleSize)
}

func ballFactory() -> SKNode {
    let physicsBody = SKPhysicsBody(circleOfRadius: ballSize)
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    physicsBody.friction = 0
    physicsBody.restitution = 1
    physicsBody.linearDamping = 0
    physicsBody.angularDamping = 0
    
    let ball = SKShapeNode(circleOfRadius: ballSize)
    ball.name = "ball"
    ball.position = ballStart
    ball.fillColor = UIColor.white
    ball.physicsBody = physicsBody
    
    return ball
}

func wallFactory(_ rect: CGRect, name: String) -> SKShapeNode {
    let physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
    physicsBody.isDynamic = false
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    physicsBody.friction = 0
    physicsBody.restitution = 1
    physicsBody.linearDamping = 0
    physicsBody.angularDamping = 0

    let wall = SKShapeNode(rect: rect)
    wall.name = name
    wall.physicsBody = physicsBody
    
    setCollision(node: wall, category: ColliderType.Wall, collision: ColliderType.Ball)

    return wall
}

func leftWallFactory(_ rect: CGRect) -> SKShapeNode {
    let rect = CGRect(x: rect.minX, y: rect.maxY, width: 1, height: rect.minY * 2)
    return wallFactory(rect, name: "left")
}

func rightWallFactory(_ rect: CGRect) -> SKShapeNode {
    let rect = CGRect(x: rect.maxX, y: rect.maxY, width: 1, height: rect.minY * 2)
    return wallFactory(rect, name: "right")
}

func topWallFactory(_ rect: CGRect) -> SKShapeNode {
    let rect = CGRect(x: rect.minX, y: rect.maxY, width: rect.maxX * 2, height: 1)
    return wallFactory(rect, name: "top")
}

func bottomWallFactory(_ rect: CGRect) -> SKShapeNode {
    let rect = CGRect(x: rect.minX, y: rect.minY, width: rect.maxX * 2, height: 1)
    return wallFactory(rect, name: "bottom")
}

func brickFactory(pos: CGPoint, color: UIColor) -> SKNode {
    let brick = SKShapeNode(rectOf: brickSize)
    brick.name = "brick"
    brick.position = pos
    brick.fillColor = color
    brick.strokeColor = color
    
    let physicsBody = SKPhysicsBody(rectangleOf: brickSize)
    physicsBody.isDynamic = false
    physicsBody.allowsRotation = false
    physicsBody.affectedByGravity = false
    physicsBody.friction = 0
    physicsBody.restitution = 0
    
    brick.physicsBody = physicsBody

    setCollision(node: brick, category: ColliderType.Brick, collision: ColliderType.Ball)
    
    return brick
}

//TODO: adjust brick width based on device width
func rowFactory(rect: CGRect, row: Int, color: UIColor) -> [SKNode] {
    var bricks: [SKNode] = []
    
    let brickWidth = Int(brickSize.width)
    let brickHeight = Int(brickSize.height)
    
    for idx in 0...13 {
        let x = -rect.maxX + CGFloat(brickWidth * idx + brickSpacing * idx + brickWidth / 2)
        let y = rect.maxY - CGFloat(brickHeight * row + brickSpacing * row + wallOffset)
        bricks.append(brickFactory(pos: CGPoint(x: x, y: y), color: color))
    }

    return bricks
}

func brickWallFactory(_ rect: CGRect) -> [[SKNode]] {
    return [
        rowFactory(rect: rect, row: 1, color: UIColor.red),
        rowFactory(rect: rect, row: 2, color: UIColor.red),
        rowFactory(rect: rect, row: 3, color: UIColor.orange),
        rowFactory(rect: rect, row: 4, color: UIColor.orange),
        rowFactory(rect: rect, row: 5, color: UIColor.green),
        rowFactory(rect: rect, row: 6, color: UIColor.green),
        rowFactory(rect: rect, row: 7, color: UIColor.yellow),
        rowFactory(rect: rect, row: 8, color: UIColor.yellow)
    ]
}

func scoreFactory(_ rect: CGRect) -> SKLabelNode {
    let scoreLabel = SKLabelNode()
    scoreLabel.name = "score"
    scoreLabel.fontName = "Helvetica"
    scoreLabel.fontSize = 60
    scoreLabel.text = "0"
    scoreLabel.position = CGPoint(x: rect.midX, y: rect.height / 2 - 100)
    return scoreLabel
}

func sceneFactory(_ rect: CGRect) -> [SKNode] {
    let rows = brickWallFactory(rect)
    
    let nodes = [
        leftWallFactory(rect),
        rightWallFactory(rect),
        topWallFactory(rect),
        bottomWallFactory(rect),
        paddleFactory(rect),
        scoreFactory(rect)
    ]

    return nodes + rows.flatMap{ $0 }
}

func messageFactory(rect: CGRect, text: String) -> SKNode {
    let label = SKLabelNode()
    label.name = "message"
    label.fontName = "Helvetica"
    label.fontSize = 40
    label.text = text
    label.position = CGPoint(x: rect.midX, y: rect.midY)
    return label
}

func turnOverFactory(_ rect: CGRect) -> SKNode {
    return messageFactory(rect: rect, text: "Turn ended! Tap to try again.")
}

func gameOverFactory(_ rect: CGRect) -> SKNode {
    return messageFactory(rect: rect, text: "Game Over! Tap to play again.")
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var game = GameState()

    var handlers = [(SKPhysicsContact, [SKNode], GameState) -> GameState]()
    
    func setupGame() {
        self.view?.showsPhysics = showPhysics
        self.physicsWorld.contactDelegate = self

        self.game = GameState()

        self.handlers = [
            ballCollisionHandler,
            brickCollisionHandler,
            topWallCollisionHandler,
            bottomCollisionHandler(self.frame)
        ]


        let nodes = sceneFactory(self.frame)
        nodes.forEach{ self.addChild($0) }
    }
    
    func startGame() {
        let ball = ballFactory()
        self.addChild(ball)
        
        let speed = CGVector(dx: ballSpeed, dy: ballSpeed)
        ball.physicsBody?.applyImpulse(speed)
        
        let label = self.childNode(withName: "message")
        label?.removeFromParent()
        
        self.game.started = true
    }
    
    func resetGame() {
        self.removeAllChildren()
        setupGame()
        startGame()
    }
    
    func moveWithTouches(touches: Set<UITouch>) {
        for t in touches {
            let pos = t.location(in: self)

            let paddle = self.childNode(withName: "paddle")
            paddle?.position.x = pos.x
        }
    }
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        self.handlers.forEach({ self.game = $0(contact, self.children, self.game) })
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!self.game.gameOver) {
            if (!self.game.started) {
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
        scoreNode.text = String(self.game.score)
    }
    
    override func didFinishUpdate()
    {
        game.nodesToRemove.forEach(){$0.removeFromParent()}
        game.nodesToAdd.forEach(){self.addChild($0)}

        game.nodesToRemove = []
        game.nodesToAdd = []
    }
}
