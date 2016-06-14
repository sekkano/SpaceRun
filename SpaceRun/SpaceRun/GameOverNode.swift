//
//  GameOverNode.swift
//  SpaceRun
//
//  Created by Corey Leavitt on 5/3/16.
//  Copyright © 2016 assignment3 Corey Leavitt. All rights reserved.
//

import SpriteKit


class GameOverNode: SKNode {

    override init() {
        super.init()
    
        let gameOverTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        gameOverTitle.fontSize = 32
        gameOverTitle.fontColor = SKColor.whiteColor()
        gameOverTitle.text = "Game Over"
        gameOverTitle.alpha = 0 //TODO: Change this to 0 after I test
        
        self.addChild(gameOverTitle)
        
        
        let fadeIn = SKAction.fadeAlphaTo(1, duration: 2)
        gameOverTitle.runAction(fadeIn)
        
        let continueTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        continueTitle.fontSize = 14
        continueTitle.fontColor = SKColor.whiteColor()
        continueTitle.text = "Tap to try again."
        continueTitle.position = CGPointMake(0, -45)
        
        self.addChild(continueTitle)
        
        continueTitle.alpha = 0
        let wait = SKAction.waitForDuration(4)
        let appear = SKAction.fadeAlphaTo(1, duration: 0.2)
        let popUp = SKAction.scaleTo(1.1, duration: 0.1)
        let dropDown = SKAction.scaleTo(1, duration: 0.1)
        let pauseAndAppear = SKAction.sequence([wait, appear, popUp, dropDown])
        
        continueTitle.runAction(pauseAndAppear)
        
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
