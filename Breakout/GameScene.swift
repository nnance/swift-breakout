//
//  GameScene.swift
//  Breakout
//
//  Created by Nick Nance on 10/7/20.
//  Copyright © 2020 Nick Nance. All rights reserved.
//

import SpriteKit
import GameplayKit

func paddleFactory(rect: CGRect) -> SKNode {
    let paddle = SKShapeNode(rectOf: CGSize(width: 140, height: 20))
    paddle.position = CGPoint(x: 0, y: -rect.maxY + 150)
    paddle.fillColor = UIColor.white

    return paddle
}

func ballFactory(rect: CGRect) -> SKNode {
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

func sceneFactory(rect: CGRect) -> [SKNode] {
    return [
        paddleFactory(rect: rect),
        ballFactory(rect: rect)
    ]
}

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        let nodes = sceneFactory(rect: self.frame)
        nodes.forEach{ self.addChild($0) }
        
        let ball = self.childNode(withName: "ball") as! SKShapeNode
        ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        border.friction = 0
        border.restitution = 1
        
        self.physicsBody = border
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
