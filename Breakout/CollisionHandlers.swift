//
//  CollisionHandlers.swift
//  Breakout
//
//  Created by Nick Nance on 10/21/20.
//  Copyright © 2020 Nick Nance. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum ColliderType: UInt32 {
    case Ball = 1
    case Paddle = 2
    case Brick = 4
    case Wall = 8
}

func increaseSpeed(_ node: SKNode) {
    guard let pb = node.physicsBody else { fatalError() }

    let amount = CGFloat(ballSpeedInc)

    if      pb.velocity.dx < 0 { pb.velocity.dx -= amount }
    else if pb.velocity.dx > 0 { pb.velocity.dx += amount }

    if      pb.velocity.dy < 0 { pb.velocity.dy -= amount }
    else if pb.velocity.dy > 0 { pb.velocity.dy += amount }
}

func calcScore(_ node: SKShapeNode) -> Int {
    return node.fillColor == UIColor.yellow
        ? scoring.yellow.rawValue
        : node.fillColor == UIColor.green
        ? scoring.green.rawValue
        : node.fillColor == UIColor.orange
        ? scoring.orange.rawValue
        : scoring.red.rawValue
}

func getBrick(_ contact: SKPhysicsContact) -> SKShapeNode? {
    return contact.bodyA.categoryBitMask == ColliderType.Brick.rawValue
        ? contact.bodyA.node as? SKShapeNode
        : contact.bodyB.categoryBitMask == ColliderType.Brick.rawValue
        ? contact.bodyB.node as? SKShapeNode
        : nil
}

func getBall(_ contact: SKPhysicsContact) -> SKShapeNode? {
    return contact.bodyA.node?.name == "ball"
        ? contact.bodyA.node as? SKShapeNode
        : contact.bodyB.node?.name == "ball"
        ? contact.bodyB.node as? SKShapeNode
        : nil
}

func getBottom(_ contact: SKPhysicsContact) -> SKShapeNode? {
    return contact.bodyA.node?.name == "bottom"
        ? contact.bodyA.node as? SKShapeNode
        : contact.bodyB.node?.name == "bottom"
        ? contact.bodyB.node as? SKShapeNode
        : nil
}

func getTop(_ contact: SKPhysicsContact) -> SKShapeNode? {
    return contact.bodyA.node?.name == "top"
        ? contact.bodyA.node as? SKShapeNode
        : contact.bodyB.node?.name == "top"
        ? contact.bodyB.node as? SKShapeNode
        : nil
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

func levelOverFactory(_ rect: CGRect) -> SKNode {
    return messageFactory(rect: rect, text: "Level Completed! Tap to continue.")
}

/*
Ball speed increases at specific intervals: after four hits, after twelve hits, and after making contact with the orange and red rows.
*/
func ballCollisionHandler(contact: SKPhysicsContact, nodes: [SKNode], state: GameState) -> GameState {
    var results = state
    
    let brick = getBrick(contact)
    let ball = getBall(contact)
    
    if ((ball != nil) && (brick != nil)) {
        results.hitCount += 1

        if results.hitCount == 4 || results.hitCount == 12 {
            increaseSpeed(ball!)
        } else if brick?.fillColor == UIColor.orange && !results.hasHitOrange {
            results.hasHitOrange = true
            increaseSpeed(ball!)
        } else if brick?.fillColor == UIColor.red && !results.hasHitRed {
            results.hasHitRed = true
            increaseSpeed(ball!)
        }
    }
    
    return results
}

/*
Yellow bricks earn one point each, green bricks earn three points, orange bricks earn five points and the top-level red bricks score seven points each.
 */
func brickCollisionHandler(_ frame: CGRect) -> (SKPhysicsContact, [SKNode],GameState) -> GameState {
    func handler(contact: SKPhysicsContact, nodes: [SKNode], state: GameState) -> GameState {
        var result = state

        let brick = getBrick(contact)

        if (brick != nil) {
            result.score += calcScore(brick!)
            result.nodesToRemove.append(brick!)
            
            let bricks = nodes.filter({ $0.name == "brick" })
            
            // level completed
            if (bricks.count == 1) {
                let levelOver = levelOverFactory(frame)
                result.nodesToAdd.append(levelOver)
                
                let ball = nodes.first(where: { $0.name == "ball" })
                result.nodesToRemove.append(ball!)
                
                result.level += 1
                result.levelOver = true
                result.started = false
            }
        }
        
        return result
    }
    return handler
}

func bottomCollisionHandler(_ frame: CGRect) -> (SKPhysicsContact, [SKNode],GameState) -> GameState {
    func handler(contact: SKPhysicsContact, nodes: [SKNode], state: GameState) -> GameState {
        var results = state
        
        let wall = getBottom(contact)
        let ball = getBall(contact)
        
        if (wall != nil && ball != nil && results.started) {
            results.started = false

            // stop the ball
            results.nodesToRemove.append(ball!)
            
            results.gameOver = results.turnsLeft == 1
            
            let label = results.gameOver
                ? gameOverFactory(frame)
                : turnOverFactory(frame)
            results.nodesToAdd.append(label)

            results.turnsLeft -= 1
        }
        
        return results
    }

    return handler
}

/*
The paddle shrinks to one-half its size after the ball has broken through the red row and hit the upper wall.
 */

func topWallCollisionHandler(contact: SKPhysicsContact, nodes: [SKNode], state: GameState) -> GameState {
    var results = state

    let wall = getTop(contact)

    if (wall != nil && wall?.name == "top" && !results.hasHitTop) {
        let paddle = nodes.first(where: { $0.name == "paddle" })
        let size = CGSize(width: paddleSize.width / 2, height: paddleSize.height)
        let smallPaddle = paddleFactory(pos: paddle!.position, paddleSize: size)
        
//        results.nodesToRemove.append(paddle!)
//        results.nodesToAdd.append(smallPaddle)
        
        results.hasHitTop = true
    }
    return results
}
