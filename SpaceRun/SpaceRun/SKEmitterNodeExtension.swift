//
//  SKEmitterNodeExtension.swift
//  SpaceRun
//
//  Created by Corey Leavitt on 4/26/16.
//  Copyright © 2016 assignment3 Corey Leavitt. All rights reserved.
//

import SpriteKit

// Us a Swift extension to extend the String class
// to have a length property
extension String {
    var length: Int {
        return self.characters.count
    }
}

extension SKEmitterNode {
    
    /*  Helper method to fetch the passed-in particle
        effect file.
    */
    class func pdc_nodeWithFile(filename: String) -> SKEmitterNode? {
        
        // We will check the file basename and extension.  If there is no
        // extension for the file name, set it to "sks".
        let basename = (filename as NSString).stringByDeletingPathExtension
        
        // get filename's extension if it has one
        var fileExt = (filename as NSString).pathExtension
        
        if fileExt.length == 0 {
            fileExt = "sks"
        }
        
        // We will grab the main bundle of our project and ask for
        // the path to a resource that has the previously calculated
        // basename and file extension.
        if let path = NSBundle.mainBundle().pathForResource(basename, ofType: fileExt) {
            
            // Particle effects in Sprite Kit are archived when created and we
            // need to unarchive the effect file so it can be treated as an
            // SKEmitterNode object.
            let node = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! SKEmitterNode
            
            return node
            
        }
        
        return nil
    }
    
    /*
        We want to add explosion to the two collisions that occur with torpedoes vs
        obstacles and obstacles vs ship.
    
        We don't want the explosion emitters to keep running indefinitely for these
        so we will make them die out after a short duration.
    */
    func pdc_dieOutInDuration(duration: NSTimeInterval) {
        
        // Define two waiting periods because once we set the birthrate to zero.
        // We will still need to wait before the particles die out.  Otherwise
        // the particles will vanish from the screen immediately.
        
        let firstWait = SKAction.waitForDuration(duration)
        // Set birthrate to zero in order to make the paricle effect disappear
        // using an SKAction code block
        let stop = SKAction.runBlock {
            
            [weak self] in
            
            if let weakSelf = self {
                
                weakSelf.particleBirthRate = 0
                
            }
            
        }
        
        // Set up the second wait time
        let secondWait = SKAction.waitForDuration(NSTimeInterval(self.particleLifetime))
        
        let remove = SKAction.removeFromParent()
        
        runAction(SKAction.sequence([firstWait, stop, secondWait, remove]))
        
    }
    
    
}
















