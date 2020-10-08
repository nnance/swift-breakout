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
    ball.position = CGPoint(x: -100, y: -100)
    ball.fillColor = UIColor.white
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
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
