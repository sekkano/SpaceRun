//
//  GameScene.swift
//  SpaceRun
//
//  Created by Corey Leavitt on 4/19/16.
//  Copyright (c) 2016 assignment3 Corey Leavitt. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    // Class properties
    private let SpaceshipNodeName = "ship"
    private let PhotonTorpedoNodeName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let HUDNodeName = "hud"
    private let HealthNodeName = "health"
    private var tapGesture = UITapGestureRecognizer()
    
    private var gameSize: CGSize?
    
    // Properties to hold sound actions
    // We will be preloading our sounds into these properties
    private let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    private let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    private let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
   
    var shieldsMaximumSound2: AVAudioPlayer! = nil
    var shieldsFailingSound: AVAudioPlayer! = nil
    var shieldsDisabledSound: AVAudioPlayer! = nil
    var shieldsIncreasingSound: AVAudioPlayer! = nil
    
    // ? means we could have nil
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: NSTimeInterval = 0
    private var lastShotFireTime: NSTimeInterval = 0
    
    private let defaultFireRate: Double = 0.5
    private var shipFireRate: Double = 0.5
    private let powerUpDuration: NSTimeInterval = 5.0
    private var shipHealthRate: CGFloat = 2.0
    
    // We will be using the explosion particle emitters over and over.
    // We don't want to load them from their .sks files evertime.
    // so instead we will create class properties and load (cache) them
    // for quick reuse like we did for our sound-related properties.
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("shipExplode.sks")!
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("obstacleExplode.sks")!
    private let shipShieldTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("forceField.sks")!
    private var particleBirthRate: CGFloat = 50
    let shipShield = SKEmitterNode.pdc_nodeWithFile("forceField.sks")
    
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupGame(self.size)
        
        
    }
    
    func setupGame(size: CGSize) {
        
        gameSize = size
        
        let path = NSBundle.mainBundle().pathForResource("shieldsMaximumPower", ofType: "wav")
        let fileURL = NSURL(fileURLWithPath: path!)
        
        
        do {
            try shieldsMaximumSound2 = AVAudioPlayer(contentsOfURL: fileURL)
        }catch{
            print(error)
        }
        
        let ship = SKSpriteNode(imageNamed: "Spaceship.png")
        ship.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Sprite Kit's resize formula (transform) is very efficient
        ship.size = CGSize(width: 40, height: 40)
        ship.name = SpaceshipNodeName
        
        addChild(ship)
        
        // Add our star field parallax effect to the scene
        // by creating an instance of our StarField class.
        addChild(StarField())
        
        // Add ship thruster particle effect to our ship
        if let shipThruster = SKEmitterNode.pdc_nodeWithFile("thrust.sks") {
            
            shipThruster.position = CGPoint(x: 0.0, y: -22.0)
            
            // Add the thruster to the ship as a child so its
            // position is relative to the ship's position
            ship.addChild(shipThruster)
            
        }
        
        
        
        shipShield!.position = CGPoint(x: 0, y: 30)
        shipShield!.particleBirthRate = particleBirthRate
        ship.addChild(shipShield!)
        
//        if let shipShield = self.shipShieldTemplate.copy() as! SKEmitterNode {
//            // Add stuff here after making forceField
//            shipShield.position = CGPoint(x: 0, y: 30)
//            ship.addChild(shipShield)
//        }
        
        
        
        // Setup our HUD
        let hudNode = HUDNode() // instantiate our HUDNode class
        hudNode.name = HUDNodeName
        
        // By default, nodes will overlap (stack) according to the order
        // in which they were added to the scene. If we want to change
        // this order, we can used a node's zPosition property to do so.
        hudNode.zPosition = 100.0
        
        // Set the position of the node to the center of the screen.
        // All of the hcild nodes of the HUD will be positioned
        // relative to this parent node's origin point.
        hudNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        
        addChild(hudNode)
        
        // Layout the score and time lables
        hudNode.layoutForScene()
        
        // Start the game already...
        hudNode.startGame()
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
        */
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        /*
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
        */
        
        
        // Grab any touches noting that touches is a "set" collection of
        // any touch event that has occured.
        
        if let touch = touches.first {
            
            /*
            // Locate the touch point
            let touchPoint = touch.locationInNode(self)
            
            // We need to reacquire a reference to our ship node
            // in the SceneGraph tree.
            
            // You can look up a Scene Graph Node by passing the node's
            // name string to the scene's childNodeWithName method.
            if let ship = self.childNodeWithName(SpaceshipNodeName) {
            
                ship.position = touchPoint
                
            }
            */
            
            self.shipTouch = touch
            
        }
        
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // If the lastUpdateTime property is zero, this is the
        // first frame rendered for this scene.  Set it to passed-in currentTime
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change (delta) since the last frame
        let timeDelta = currentTime - lastUpdateTime
        
        // If the touch is still there (since shipTouch is a weak reference,
        // it will automatically set to nil by the touch-handling system
        // when it releases the touches after they are done), find the ship
        // node in the Scene Graph by it's name and update it's position
        // property to the point on the screen that was touched.
        //
        // This happens every frame (because we are inside update()) so the
        // ship will keep up with where ever the user's finger moves to...
        
        if let shipTouch = self.shipTouch {
            
            /*
            if let ship = self.childNodeWithName(SpaceshipNodeName) {
                ship.position = shipTouch.locationInNode(self)
            }
            */
            moveShipTowardPoint(shipTouch.locationInNode(self), timeDelta: timeDelta)
            
            // We only want photon torpedos to launch from our ship when
            // users finger is in contact with screen AND if the difference
            // between current time and last time a torpedo was fired is greater
            // than a half second.
            if currentTime - lastShotFireTime > shipFireRate{
                
                shoot()
                lastShotFireTime = currentTime
            }
        }
        
        // We want to release asteroid obstacles 1.5% of the time a frame is drawn
        if arc4random_uniform(1000) <= 15 {
            
            dropThing()
            
        }
        
        // Check for any collisions before each frame is rendered
        checkCollisions()
        shieldEnergy()
        
        // Update lastUpdateTime to current time
        lastUpdateTime = currentTime
    } // End of update() function
    
    // Nudge the ship toward the touch point by an appropriate distance amount
    // based on elapsed time (timeDelta) since the last frame.
    func moveShipTowardPoint(point: CGPoint, timeDelta: NSTimeInterval) {
        
        // Points per second the ship should travel
        let shipSpeed = CGFloat(350)
        
        if let ship = self.childNodeWithName(SpaceshipNodeName) {
            // Using the Pythagorean Theorem, determine the distance
            // between ship's current position and the point that
            // was passed in (touchPoint).
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            // If the distance left to travel is greater than 4 points, 
            // keep moving the ship.
            // Otherwise, stop moving the ship because we may experience
            // "jitter" around the touch point (due to imprecision in
            // floating point numbers) if we get too close.
            
            if distanceLeftToTravel > 4 {
                
                // Calculate how far we should move the ship during this frame
                // Casting timeDelta to CGFloat
                let howFarToMove = CGFloat(timeDelta) * CGFloat(shipSpeed)
                
                // Convert the distance remaining babck into (x, y) coordinates
                // using the atan2() function to determine the proper angle
                // based on ship's position and destination
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                // Then, using the angle along with sine and cosine trig functions,
                // determine the x and y offset values.
                let xOffset = howFarToMove * cos(angle)
                let yOffset = howFarToMove * sin(angle)
                
                // Use the offsets to reposition the ship
                ship.position = CGPoint( x: ship.position.x + xOffset,  y: ship.position.y + yOffset)
                
            }
            
        }
        
    }
    
    func shoot() {
     
        if let ship = self.childNodeWithName(SpaceshipNodeName) {
            
            // Create a photon sprite
            let photon = SKSpriteNode(imageNamed: "photon")
            photon.name = PhotonTorpedoNodeName
            photon.position = ship.position
            
            self.addChild(photon)
            
            // Move the torpedo from it's original position (ship.position)
            // past the top edge of the screen over half a second.
            // Y-axis in sprite kit is flipped back to normal. (0, 0) is the bottom
            // left corner and scene height (self.size.height) is the top
            // edge of the scene.
            
            // With actions you have to set up then run them
            let fly = SKAction.moveByX(0, y: self.size.height + photon.size.height, duration: 0.5)
            
            // Run the previous Actions
            //photon.runAction(fly)
            
            // Set up action to clean up the torpedo
            // Remove the torpedo once it leaves the scene
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.runAction(fireAndRemove)
            self.runAction(self.shootSound)
        }
    }
    
    // Create a power up sprite which spins and moves from top to  bottom
    func dropWeaponsPowerUp() {
        
        let sideSize = 30.0
        
        // arc4random_uniform requires a UInt32 parameter value to be passed to it
        // Determine starting x-position for the powerup
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        // starting y-position above top edge of scene/screen
        let startY = Double(self.size.height) + sideSize
        
        // Create and configure the power up sprite
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        // Set up powerup's movement
        let powerUpPath = buildEnemyShipMovementPath()
        let flightPath = SKAction.followPath(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        let remove = SKAction.removeFromParent()
        
        powerUp.runAction(SKAction.sequence([flightPath, remove]))
    }
    
    func dropEnemyShip() {
        
        let sideSize = 30.0
        
        // arc4random_uniform requires a UInt32 parameter value to be passed to it
        // Determine starting x-position for the asteroid
        let startX = Double(arc4random_uniform(uint(self.size.width - 40)) + 20)
        // starting y-position above top edge of scene/screen
        let startY = Double(self.size.height) + sideSize
        
        // Create and configure the enemy ship sprite
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        enemy.size = CGSize(width: sideSize + 20, height: sideSize + 20)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        // Set up enemy ship movement
        //
        // We want the enemy ship to follow a curved path (Bezier Curve)
        // Which uses control points to define how the curve of the path
        // is formed.  The following method call will return the path.
        let shipPath = buildEnemyShipMovementPath()
        
        // Use the provided ship path to move our enemy ship.
        //
        // asOffset parameter: if set to true, lets us treat the
        // actual point values of the path as offsets from the enemy ship's
        // starting point.  A false value would treat the path's points
        // as absolute positions on the screen.
        //
        // orientToPath parameter: if true, causes the enemy ship to turn
        // and face the direction of the path automatically.
        let followPath = SKAction.followPath(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        let remove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([followPath, remove]))

    }

    func buildEnemyShipMovementPath() ->CGPathRef {
        
        let yMax = -1.0 * self.size.height - 80
        
        // Bezier path was produced using PaintCode app (www.paintcodeapp.com)
        // Use the UIBezier Path class to build an object that adds points
        // with two control points (per point) to construct a curved path
        //
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPointMake(0.5, -0.5))
        
        bezierPath.addCurveToPoint(CGPointMake(-2.5, -59.5), controlPoint1: CGPointMake(0.5, -0.5), controlPoint2: CGPointMake(4.55, -29.48))
        
        bezierPath.addCurveToPoint(CGPointMake(-27.5, -154.5), controlPoint1: CGPointMake(-9.55, -89.52), controlPoint2: CGPointMake(-43.32, -115.43))
        
        bezierPath.addCurveToPoint(CGPointMake(30.5, -243.5), controlPoint1: CGPointMake(-11.68, -193.57), controlPoint2: CGPointMake(17.28, -186.95))
        
        bezierPath.addCurveToPoint(CGPointMake(-52.5, -379.5), controlPoint1: CGPointMake(43.72, -300.05), controlPoint2: CGPointMake(-47.71, -335.76))
        
        bezierPath.addCurveToPoint(CGPointMake(54.5, -449.5), controlPoint1: CGPointMake(-57.29, -423.24), controlPoint2: CGPointMake(-8.14, -482.45))
        
        bezierPath.addCurveToPoint(CGPointMake(-5.5, -348.5), controlPoint1: CGPointMake(117.14, -416.55), controlPoint2: CGPointMake(52.25, -308.62))
        
        bezierPath.addCurveToPoint(CGPointMake(10.5, -494.5), controlPoint1: CGPointMake(-63.25, -388.38), controlPoint2: CGPointMake(-14.48, -457.43))
        
        bezierPath.addCurveToPoint(CGPointMake(0.5, -559.5), controlPoint1: CGPointMake(23.74, -514.16), controlPoint2: CGPointMake(6.93, -537.57))
        
        //bezierPath.addCurveToPoint(CGPointMake(-2.5, -644.5), controlPoint1: CGPointMake(-5.2, -578.93), controlPoint2: CGPointMake(-2.5, -644.5))
        
        bezierPath.addCurveToPoint(CGPointMake(-2.5, yMax), controlPoint1: CGPointMake(-5.2, yMax), controlPoint2: CGPointMake(-2.5, yMax))
        
        return bezierPath.CGPath
        
    }
    
    func checkCollisions() {
        
        let path = NSBundle.mainBundle().pathForResource("shieldsFailing", ofType: "wav")
        let fileURL = NSURL(fileURLWithPath: path!)
        
        let disabledPath = NSBundle.mainBundle().pathForResource("shieldsDisabled", ofType: "wav")
        let disabledURL = NSURL(fileURLWithPath: disabledPath!)
        
        let increasePath = NSBundle.mainBundle().pathForResource("increasingShieldPower", ofType: "wav")
        let increaseURL = NSURL(fileURLWithPath: increasePath!)
        
        if let ship = self.childNodeWithName(SpaceshipNodeName) {
            
            enumerateChildNodesWithName(PowerupNodeName) {
                myPowerUp, _ in
                
                if ship.intersectsNode(myPowerUp) {
                    // Show powerup HUD Timer countdown
                    if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                        
                        hud.showPowerupTimer(self.powerUpDuration)
                    }

                    
                    myPowerUp.removeFromParent()
                    
                    // Increase the ships fire rate for a period of 5 seconds
                    self.shipFireRate = 0.1
                    
                    // But, we need to power back down after a delay.
                    let powerDown = SKAction.runBlock {
                        
                        self.shipFireRate = self.defaultFireRate
                        
                    }
                    
                    // Now, let's set up our delay before powerDown occurs
                    let wait = SKAction.waitForDuration(self.powerUpDuration)
                    let waitAndPowerDown = SKAction.sequence([wait, powerDown])
                    
                    /*
                        If we collect an additional power up, while one is
                        already in progress. We need to stop the previous one
                        and start a new one so we always get the full duration
                        for the new one.
                    
                        Sprite kit lets us run actions with a key that we can
                        use to identify and remove the action before it has
                        had a chance to run or finish.
                        
                        If no key is found, nothing happens...
                    */
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeActionForKey(powerDownActionKey)
                    
                    ship.runAction(waitAndPowerDown, withKey: powerDownActionKey)
                    
                    
                    
                }
                
                
            }
            
            // This method will execute the given code block for
            // every node that is an obstacle node. This will iterate
            // through all of our obtacle nodes in the Scene Graph tree.
            //
            // enumerateChildNodesWithName will automatically populate
            // the local identifier obstacle with a reference to the next
            // "obstacle" node it found as it is looping through the Scene
            // Graph tree.
            //
            enumerateChildNodesWithName(ObstacleNodeName) {
                
                obstacle, _ in
                
                
                // Check for collision with our ship
                
                if ship.intersectsNode(obstacle) {
                    
                    self.shipHealthRate -= 1
                    do{
                        try self.shieldsFailingSound = AVAudioPlayer(contentsOfURL: fileURL)
                        try self.shieldsDisabledSound = AVAudioPlayer(contentsOfURL: disabledURL)
                        
                        if self.shipHealthRate >= 2 {
                            self.shieldsFailingSound.play()
                            self.shieldsFailingSound.volume = 10
                        }else if self.shipHealthRate == 1{
                            self.shieldsDisabledSound.play()
                            self.shieldsDisabledSound.volume = 10
                        }

                    }catch{
                        print(error)
                    }
                    
                    
                    if self.shipHealthRate <= 0 {
                        // Our ship collided with an obstacle
                        //
                        // Set shipTouch property to nil so it will not
                        // be used by our shooting logic in the update function
                        // to continue to track the touch and shoot a
                        // photon torpedo.  If this doesn't work
                        // the torpedo will be shot from (0,0) since the
                        // ship is gone.
                        //
                        self.shipTouch = nil
                        ship.removeFromParent()
                        
                        let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                        

                        explosion.position = ship.position
                        explosion.pdc_dieOutInDuration(0.3)
                        self.addChild(explosion)
                        
                        if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                            hud.endGame()
                        }
                        
                        //TODO: ADD in here to add logic to restart the game.
                       
                        self.endGame()
                        
                    }
                   
                    
                    // Remove the ship and the obstacle that hit it
                    
                    obstacle.removeFromParent()
                    self.runAction(self.shipExplodeSound)
                    
                    let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                    
                    explosion.position = obstacle.position
                    explosion.pdc_dieOutInDuration(0.1)
                    self.addChild(explosion)
                    
                    
                   
                    
                    /*
                        Call a method called copy() on the node in the shipExplodeTemplate
                        property because nodes can only be added to a scene once.
                        
                        If we try to add a node again that already exists in a scene
                        the game will crash with an error. We must add copies of
                        particle emitters nodes that we wish to use more than once and
                        we will use the emitter node template in our cached property as
                        a template from which to make these copies.

                    */
                    
                   
                    
                
                }
                
                // Now check if the obstacle collided with a photon torpedo
                //
                // Add an inner loop (enumeration) to check if any of our
                // photon torpedo collided with the obstacle
                self.enumerateChildNodesWithName(self.PhotonTorpedoNodeName) {
                    myPhoton, stop in
                    
                    if myPhoton.intersectsNode(obstacle) {
                        
                        // Remove both torpedo and obstacle from scene
                        myPhoton.removeFromParent()
                        obstacle.removeFromParent()
                        self.runAction(self.obstacleExplodeSound)
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        explosion.pdc_dieOutInDuration(0.1)
                        self.addChild(explosion)
                        
                        // Update our score
                        if let hud = self.childNodeWithName(self.HUDNodeName) as! HUDNode? {
                            let score = 10
                            
                            hud.addPoints(score)
                        }

                        
                        // Set stop.memory to true to end this inner loop
                        // This is like a break statement in other languages
                        stop.memory = true
                        
                    }
                   
                
                    
                    
                } // EndmenumerateChildNodesWithName(self.PhotonTorpedoNodeName)
                
            } // End enumerateChildNodesWithName(ObstacleNodeName)
            
            
            self.enumerateChildNodesWithName(self.HealthNodeName) {
                health, _ in
                
                if ship.intersectsNode(health) {
                    health.removeFromParent()
                    
                    do{
                        try self.shieldsIncreasingSound = AVAudioPlayer(contentsOfURL: increaseURL)
                    }catch{
                        print(error)
                    }
                    if self.shipHealthRate < 4 {
                        self.shipHealthRate += 1
                        self.shieldsIncreasingSound.play()
                        self.shieldsIncreasingSound.volume = 10
                        
                    }
                    if self.shipHealthRate == 4 {
                        if self.shieldsIncreasingSound.playing {
                        
                            self.shieldsIncreasingSound.stop()
                            self.shieldsMaximumSound2.play()
                            self.shieldsMaximumSound2.volume = 10
                        }else{
                            self.shieldsMaximumSound2.play()
                            self.shieldsMaximumSound2.volume = 10
                        }
                        
                        
                    }
                }
            }
            
        }
    }
    
    // Choose randomly when to drop an enemy ship, asteroid, powerup, or whatever...
    func dropThing() {
        
        let dieRoll = arc4random_uniform(100) // Die roll between 0 - 99
        
        if dieRoll < 10 {
            dropHealth()
        }else if dieRoll < 15 {
            dropWeaponsPowerUp()
        }else if dieRoll < 30{
            dropEnemyShip()
        }else{
            dropAsteroid()
        }
        
    }
    
    func dropAsteroid() {
        
        // Define asteroid size which will be a random number between 15 - 44
        let sideSize = Double(arc4random_uniform(30) + 15)
        
        // Maximum x-value for the scene
        let maxX = Double(self.size.width)
        let quarterX = maxX / 4.0
        let randRange = UInt32(maxX + (quarterX * 2))
        
        // arc4random_uniform requires a UInt32 parameter value to be passed to it
        // Determine starting x-position for the asteroid
        let startX = Double(arc4random_uniform(randRange)) - quarterX
        // starting y-position above top edge of scene/screen
        let startY = Double(self.size.height) + sideSize
        
        // Random ending x-position
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        let endY = 0.0 - sideSize
        
        // Create our asteroid sprite and set it properties
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        asteroid.position = CGPoint(x: startX, y: startY)
        
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        // Run some actions to get our asteroid moving
        // Move our asteroid to a randomly generated point
        // Over a duration of 3-6 seconds.
        let move = SKAction.moveTo(CGPoint(x: endX, y: endY), duration: Double(arc4random_uniform(4) + 3))
        let remove = SKAction.removeFromParent()
        
        let travelAndRemove = SKAction.sequence([move, remove])
        // As it is moving, rotate the asteroid by 3 radians (just under 180 degress)
        // over a 1-3 seconds duration
        let spin = SKAction.rotateByAngle(3, duration: Double(arc4random_uniform(3) + 1))
        
        let spinForever = SKAction.repeatActionForever(spin)
        let all = SKAction.group([spinForever, travelAndRemove])
        
        asteroid.runAction(all)
    }
    
    func dropHealth() {
        
        let sideSize = 30.0
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        let startY = Double(self.size.height) + sideSize
        let shipHealth = SKSpriteNode(imageNamed: "healthPowerUp")
        
        shipHealth.size = CGSize(width: 20.0, height: 20.0)
        shipHealth.position = CGPoint(x: startX, y: startY)
        shipHealth.name = HealthNodeName
        
        self.addChild(shipHealth)
        let healthPowerUpPath = buildEnemyShipMovementPath()
        let healthPath = SKAction.followPath(healthPowerUpPath, asOffset: true, orientToPath: true, duration: 5.0)
        let remove = SKAction.removeFromParent()
        
        shipHealth.runAction(SKAction.fadeAlphaTo(0, duration: 5))
        shipHealth.runAction(SKAction.scaleTo(0.5, duration: 5))
        shipHealth.runAction(SKAction.sequence([healthPath, remove]))
        
        
    }
    
    func shieldEnergy() {
        
        if shipHealthRate < 2 {
            shipShield!.particleBirthRate = 0
        }else if shipHealthRate < 3 {
            shipShield!.particleBirthRate = 50
        }else if shipHealthRate < 4 {
            shipShield!.particleBirthRate = 100
        }else if shipHealthRate == 4 {
            shipShield!.particleBirthRate = 200
        }
        
    }
    
    func endGame() {
        
        // Creates a tap gesture
        // "tapped" is the function tapped() and will be called on the tapped gesture
        self.tapGesture = UITapGestureRecognizer(target: self, action: "tapped")
        
        // Adds the tapGesture to the scene
        self.view?.addGestureRecognizer(tapGesture)
        
        // Get the GameOverNode and pop up the game over text
        let node = GameOverNode()
        node.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        self.addChild(node)
    }
    
    func tapped() {
        
        // Removes the tap gesture and resets the game.
        self.view?.removeGestureRecognizer(self.tapGesture)
        reset()
    }
    
    func reset() {
        self.removeAllActions()
        self.removeAllChildren()
        setupGame(gameSize!)
        shipHealthRate = 2.0
        
    }
}

    




















