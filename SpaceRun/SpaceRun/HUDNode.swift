//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Corey Leavitt on 4/28/16.
//  Copyright © 2016 assignment3 Corey Leavitt. All rights reserved.
//

import SpriteKit

/*
    Create a HUD that will hold all our display areas.

    Once the node is added to the scene, we will tell it to
    lay out its child nodes.
    The child noces will not contain lables as we will use the blank
    nodes as group containers and lay out the label nodes inside of them.

    We will left-align the score and right-align the elapsed game time.
*/

class HUDNode: SKNode {
    
    // Build two parent nodes as groups to hold the score and elapsed time
    // Each group will have a title and value label.
    
    // Class properties
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    
    private let ElapsedGroupName = "elapsedGroup"
    private let ElapsedValueName = "elapsedValue"
    private let TimerActionName = "elapsedGameTimer"
    
    private let PowerupGroupName = "powerupGroup"
    private let PowerupValueName = "powerupValue"
    private let PowerupTimerActionName = "powerupGameTimer"
    
    var elapsedTime: NSTimeInterval = 0.0
    var score: Int = 0
    
    lazy private var scoreFormatter: NSNumberFormatter = {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        
        return formatter
        
    }()
    
    lazy private var timeFormatter: NSNumberFormatter = {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        
        return formatter
        
    }()
    
    // Our class initializer
    override init() {
        super.init()
        
        // Build an empty SKNode as our containing group and
        // name it "scoreGroup" so we can get a reference to it
        // later from the scene graph using this name.
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        // Score title setup.
        // Create an SKLabelNode for our score title label
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.whiteColor()
        
        // Set the vertical and horizontal alignment modes in a way
        // that will help us lay out the labels inside this group node.
        scoreTitle.horizontalAlignmentMode = .Left
        scoreTitle.verticalAlignmentMode = .Bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        scoreGroup.addChild(scoreTitle)
        
        // The child nodes are positioned relative to the parent node's origin
        // (parent is scoreGroup)
        //
        // Score value set up
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.whiteColor()
        
        // Set the vertical and horizontal alignment modes in a way
        // that will help us lay out the labels inside this group node.
        scoreValue.horizontalAlignmentMode = .Left
        scoreValue.verticalAlignmentMode = .Top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        scoreGroup.addChild(scoreValue)
        
        // Add scoreGroup to our HUDNode
        addChild(scoreGroup)
        
        
        
        
        
        // We need to do the same setup for our elapsed time.
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        // Score title setup.
        // Create an SKLabelNode for our score title label
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.whiteColor()
        
        // Set the vertical and horizontal alignment modes in a way
        // that will help us lay out the labels inside this group node.
        elapsedTitle.horizontalAlignmentMode = .Right
        elapsedTitle.verticalAlignmentMode = .Bottom
        elapsedTitle.text = "TIME"
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        // The child nodes are positioned relative to the parent node's origin
        // (parent is elapsedGroup)
        //
        // Score value set up
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.whiteColor()
        
        // Set the vertical and horizontal alignment modes in a way
        // that will help us lay out the labels inside this group node.
        elapsedValue.horizontalAlignmentMode = .Right
        elapsedValue.verticalAlignmentMode = .Top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = "0.0s"
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        // Add elapsedGroup to our HUDNode
        addChild(elapsedGroup)
        
        
        
        
        
        // We need to do the same setup for our Weapons Powerup time.
        let powerupGroup = SKNode()
        powerupGroup.name = PowerupGroupName
        
        // Powerup title setup.
        // Create an SKLabelNode for our score title label
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.redColor()
        
        // Set the vertical alignment modes in a way
        // that will help us lay out the labels inside this group node.
        
        powerupTitle.verticalAlignmentMode = .Bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // Set up actions to make our power up timer pulse.
        let scaleUp = SKAction.scaleTo(1.3, duration: 0.3)
        let scaleDown = SKAction.scaleTo(1.0, duration: 0.3)
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        powerupTitle.runAction(SKAction.repeatActionForever(pulse))
        
        
        powerupGroup.addChild(powerupTitle)
        
        // The child nodes are positioned relative to the parent node's origin
        // (parent is elapsedGroup)
        //
        // Score value set up
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.redColor()
        
        // Set the vertical alignment modes in a way
        // that will help us lay out the labels inside this group node.
        powerupValue.verticalAlignmentMode = .Top
        powerupValue.name = PowerupValueName
        powerupValue.text = "0s left"
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        
        powerupGroup.addChild(powerupValue)
        
        // Add elapsedGroup to our HUDNode
        addChild(powerupGroup)
        
        powerupGroup.alpha = 0.0 // Make it invisible to start.


        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
        Our labels are properly layed out within their parent group nodes,
        but the group nodes are cnetered on teh screen. We need to create
        some layout method so that these group nodes are properly positioned
        to the top-left and top right corners when this HUDNode is added to the screen.
    */
    func layoutForScene() {
        
        // NOTE: When a node exists in the Scene Graph, it can get access
        // to the scene via its scene property. That property is nil
        // if the node doesn't belong to the scene yet, so this method
        // is useless if the node is not yet added to a scene.
        if let scene = scene {
            
            let sceneSize = scene.size
            
            // This will be used to calculate position of each group
            var groupSize = CGSizeZero
            
            if let scoreGroup = childNodeWithName(ScoreGroupName) {
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width / 2.0 + 20.0, y: sceneSize.height / 2.0 - groupSize.height)
            }else{
                assert(false, "No score group node was found in the Scene Graph tree")
            }
            
            
            
            if let elapsedGroup = childNodeWithName(ElapsedGroupName) {
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width / 2.0 - 20.0, y: sceneSize.height / 2.0 - groupSize.height)
            }else{
                assert(false, "No elapsed group node was found in the Scene Graph tree")
            }
            
            if let powerupGroup = childNodeWithName(PowerupGroupName) {
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height / 2.0 - groupSize.height)
            }else{
                assert(false, "No powerup group node was found in the Scene Graph tree")
            }

            
            
        }
        
    }
    
    // Show our weapons power up timer.
    func showPowerupTimer(time: NSTimeInterval) {
        
        // Look up our PowerupGroup by name
        if let powerupGroup = childNodeWithName(PowerupGroupName) {
            
            // Remove any existing action with the following key
            // because we want to restart the timer as we are calling this method
            // as a result of the player collecting another weapons power up.
            powerupGroup.removeActionForKey(PowerupTimerActionName)
            
            // Look up the powerValue by name
            if let powerupValue = powerupGroup.childNodeWithName(PowerupValueName) as! SKLabelNode?{
            
                // Run the count down sequence
                
                // The action will repeat it's self every 0.05 seconds in order
                // to update the textin the powerUpValue label.
                
                // We will reuse the self.timeFormatter so we need to use a weak reference
                // to self to ensure the block does not retain self which would produce a memory leak.
                let start = NSDate.timeIntervalSinceReferenceDate()
                
                let block = SKAction.runBlock {
                    [weak self] in
                    
                    if let weakSelf = self {
                        
                        let elapsedTime = NSDate.timeIntervalSinceReferenceDate() - start
                        let timeLeft = max(time - elapsedTime, 0)
                        let timeLeftFormat = weakSelf.timeFormatter.stringFromNumber(timeLeft)!
                        powerupValue.text = "\(timeLeftFormat)s left"
                    }
                    
                    
                }
                
                // Actions
                let countDownSequence = SKAction.sequence([block, SKAction.waitForDuration(0.05)])
                let countDown = SKAction.repeatActionForever(countDownSequence)
                
                let fadeIn = SKAction.fadeAlphaTo(1, duration: 0.1)
                let wait = SKAction.waitForDuration(time)
                let fadeOut = SKAction.fadeAlphaTo(0.0, duration: 1)
                
                let stopAction = SKAction.runBlock({ () -> Void in
                
                    powerupGroup.removeActionForKey(self.PowerupTimerActionName)
                
                })
                
                let visuals = SKAction.sequence([fadeIn, wait, fadeOut, stopAction])
                powerupGroup.runAction(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
            }
            
        }
        
    }
    
    // This method will add new points to the score
    func addPoints(points: Int) {
        
        score += points
        
        // Look up our score value label in the SceneGraph by name
        if let scoreValue = childNodeWithName("\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            // Format our score with the thousands separator so here is where we will use
            // our cached self.scoreFormatter property.
            scoreValue.text = scoreFormatter.stringFromNumber(score)
            
            // Scale the node up for a brief period and then scale it back down.
            let scale = SKAction.scaleTo(1.1, duration: 0.02)
            let shrink = SKAction.scaleTo(1.0, duration: 0.07)
            
            scoreValue.runAction(SKAction.sequence([scale, shrink]))
        }
        
    }
    
    func startGame() {
        
        // Calculate the timestamp when starting the game
        let startTime = NSDate.timeIntervalSinceReferenceDate()
        
        if let elapsedValue = childNodeWithName("\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode?{
            
            // Use a code block to update the elapsedTime property to be the difference
            // between the start time and the current timestamp.
            let update = SKAction.runBlock({
            [weak self] in
                
            if let weakSelf = self {
            
                let currentTime = NSDate.timeIntervalSinceReferenceDate()
                let elapsedTime = currentTime - startTime
                weakSelf.elapsedTime = elapsedTime
                
                elapsedValue.text = weakSelf.timeFormatter.stringFromNumber(elapsedTime)
                
                
            }
        })
        
        let updateAndDelay = SKAction.sequence([update, SKAction.waitForDuration(0.05)])
        let timer = SKAction.repeatActionForever(updateAndDelay)
        runAction(timer, withKey: TimerActionName)
            
            
        }
        
    }
    
    func endGame() {
        
        // Stop the timer sequence
        removeActionForKey(TimerActionName)
        // If the game ends while a powerup countdown is in progress
        // fade the powerup HUD away. If not in progress do nothing.
        if let powerupGroup = childNodeWithName(PowerupGroupName) {
            
            powerupGroup.removeActionForKey(PowerupTimerActionName)
            powerupGroup.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.3))
            
        }
        
    }
}





















