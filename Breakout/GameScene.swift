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
let paddleWidth = 80
let paddleHeight = 20
let brickWidth = 54
let brickHeight = 20
let brickSpacing = 4
let wallOffset = 200

func paddleFactory(rect: CGRect) -> SKNode {
    let size = CGSize(width: paddleWidth, height: paddleHeight)
    let paddle = SKShapeNode(rectOf: size)
    paddle.position = CGPoint(x: 0, y: -rect.maxY + 150)
    paddle.fillColor = UIColor.white
    
    paddle.physicsBody = SKPhysicsBody(rectangleOf: size)
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
    
    return ball
}

func brickFactory(pos: CGPoint, color: UIColor) -> SKNode {
    let size = CGSize(width: brickWidth, height: brickHeight)
    let brick = SKShapeNode(rectOf: size)
    brick.position = pos
    brick.fillColor = color
    brick.strokeColor = color
    
    brick.physicsBody = SKPhysicsBody(rectangleOf: size)
    brick.physicsBody?.isDynamic = false
    brick.physicsBody?.allowsRotation = false
    brick.physicsBody?.affectedByGravity = false
    brick.physicsBody?.friction = 0
    brick.physicsBody?.restitution = 0

    return brick

}

//TODO: adjust brick width based on device width
func rowFactory(rect: CGRect, row: Int, color: UIColor) -> [SKNode] {
    var bricks: [SKNode] = []
    
    for idx in 0...12 {
        let x = -rect.maxX + CGFloat(brickWidth * idx + brickSpacing * idx + brickWidth / 2)
        let y = rect.maxY - CGFloat(brickHeight * row + brickSpacing * row + wallOffset)
        bricks.append(brickFactory(pos: CGPoint(x: x, y: y), color: color))
    }

    return bricks
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
        ballFactory()
    ] + rows.flatMap{ $0 }
}

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        let nodes = sceneFactory(rect: self.frame)
        nodes.forEach{ self.addChild($0) }
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        border.friction = 0
        border.restitution = 1
        
        self.physicsBody = border
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let ball = self.childNode(withName: "ball") as! SKShapeNode
        ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
