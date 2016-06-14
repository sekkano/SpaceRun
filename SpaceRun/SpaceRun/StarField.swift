//
//  StarField.swift
//  SpaceRun
//
//  Created by Corey Leavitt on 4/26/16.
//  Copyright © 2016 assignment3 Corey Leavitt. All rights reserved.
//

import SpriteKit

class StarField: SKNode {
    
    override init() {
        super.init()
        initSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init()
        initSetup()
    }
    
    func initSetup() {
        
        /*
            Because we need to call a method on self from inside a code block,
            we must create a weak reference to it. This is what we are doing
            with our weakSelf constant.
        
            Why? The action holds a strong reference to the block and the node
            holds a strong reference to the action.  If the block held a strong
            reference to the node (self in this case) then the action, the block
            and the node would form a retain cycle and never get deallocated.
            => Memory Leak.
        */
        
        let update = SKAction.runBlock {
            [weak self] in
            
            if arc4random_uniform(10) < 3 {
                if let weakSelf = self {
                    weakSelf.launchStar()
                }
            }
            
            
        } // end update code block
        
        let delay = SKAction.waitForDuration(0.01)
        
        let updatedLoop = SKAction.sequence([delay, update])
        
        runAction(SKAction.repeatActionForever(updatedLoop))
        
    } // End of initSetup
    
    func launchStar() {
        
        // Make sure we have a reference to our scene
        if let scene = self.scene {
            
            // Calculate a random starting point at top of screen
            let randX = Double(arc4random_uniform(uint(scene.size.width)))
            let maxY = Double(scene.size.height)
            let randomStart = CGPoint(x: randX, y: maxY)
            let star = SKSpriteNode(imageNamed: "shootingStar")
            
            star.position = randomStart
            
            //star.size = CGSize(width: 2.0, height: 10.0)
            
            star.alpha = 0.1 + (CGFloat(arc4random_uniform(10)) / 10.0)
            star.size = CGSize(width: 3.0, height: 8.0 - star.alpha)
            
            
            
            // Stack from dimmest to brightest in z-axis
            star.zPosition = -100 + star.alpha * 10
            
            addChild(star)
            
            // Move the star toward the bottom of the screen using a random duration
            // between 0.1 and 1 second removing the star when it passed the bottom edge.
            // 
            // The different speeds of the stars (based on duration) will give
            // the illusion of parallax effect.
            
            let destY = 0.0 - scene.size.height - star.size.height
            //let duration = 0.1 + (Double(arc4random_uniform(10)) / 10.0)
            let duration = Double(-star.alpha + 1.8)
            
            star.runAction(SKAction.sequence([SKAction.moveByX(0.0, y: destY, duration: duration), SKAction.removeFromParent()]))
            
            
            
            
        }
        
    }
    
    
    
}

























