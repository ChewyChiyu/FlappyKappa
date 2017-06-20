//
//  GameScene.swift
//  FlappyKappa
//
//  Created by Evan Chen on 6/19/17.
//  Copyright © 2017 Evan Chen. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = Kappa()
    
    var groundAlpha = SKSpriteNode()
    var groundBeta = SKSpriteNode()
    
    var groundAnchorAlpha = CGPoint()
    var groundAnchorBeta = CGPoint()
    
    var pipes = SKNode()
    
    var startGame:Bool = false
    var isAlive:Bool = true
    
    var score:Int = 0
    
    var scoreLabel = SKLabelNode()
    
    var jumpSound: AVAudioPlayer?
    var musicSound: AVAudioPlayer?

    override func didMove(to view: SKView) {
        
        player = (self.childNode(withName: "Kappa") as! Kappa)
        
        
        groundAlpha = (self.childNode(withName: "GroundAlpha") as! SKSpriteNode)
        groundBeta = (self.childNode(withName: "GroundBeta") as! SKSpriteNode)
        groundAnchorAlpha = groundAlpha.position
        groundAnchorBeta = groundBeta.position
        
        pipes = (self.childNode(withName: "Obstacles")!)
        
        scoreLabel = (self.childNode(withName: "ScoreLabel")! as! SKLabelNode)
        scoreLabel.fontSize = 60
        scoreLabel.fontName = "HelveticaNeue-Bold"
        
        physicsWorld.contactDelegate = self
        //being music
        playMusic()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let pointA = contact.bodyA
        let pointB = contact.bodyB
        if(pointA.categoryBitMask == 1 && pointB.categoryBitMask == 8 || pointB.categoryBitMask == 1 && pointA.categoryBitMask == 8){
            // kappa and target
            score+=1
        }else{
            //kappa hit something else so died
            isAlive = false
            //death animation + impulse
            player.physicsBody?.applyImpulse(CGVector(dx: -40, dy: 40))
            player.zPosition  = 1
            player.physicsBody?.collisionBitMask = 0
            player.physicsBody?.contactTestBitMask = 0
            
            
            player.run(SKAction(named: "SpinOut")!,  completion: {
                //restarting
                self.stopMusic()
                if let scene = GameScene(fileNamed:"GameScene") {
                    let skView = self.view! as SKView
                    
                    skView.ignoresSiblingOrder = true
                    
                    scene.scaleMode = .aspectFill
                    scene.size = skView.bounds.size
                    
                    
                    
                    skView.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
                }
                
            })
            
            
            
            
        }
        return
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame = true
        if(startGame && isAlive){
            player.physicsBody?.affectedByGravity = true
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 65))
            playJumpSound()
        }
        
    }
    
    func playJumpSound(){
        
        let path = Bundle.main.path(forResource: "smb_kick.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            jumpSound = sound
            sound.volume*=2
            sound.play()
        } catch {
            // couldn't load file :(
        }
        
    }
    func playMusic(){
        let path = Bundle.main.path(forResource: "Super Mario Bros. medley.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            musicSound = sound
            sound.numberOfLoops = -1 //chained forever
            sound.play()
        } catch {
            // couldn't load file :(
        }
    }
    func stopMusic(){
        if musicSound != nil {
            musicSound?.stop()
            musicSound = nil
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(startGame && isAlive){
            managePipes()
            manageGround()
            manageScore()
        }
    }
    
    func manageScore(){
        scoreLabel.text = String(score)
    }
    func managePipes(){
        //move pipes
        
        for pipe in pipes.children as! [SKReferenceNode] {
            pipe.position.x-=2
            //reset position of pipe if past
            if(pipe.position.x <= -36){
                //tamper with height
                changeHeight(selected: pipe)
                //shift back
                pipe.position.x+=600
                
            }
            
        }
        
        
        
    }
    func changeHeight(selected: SKReferenceNode){
        //oops messed up on position in .sks files... gotta adapt to strange y position of -175.973 for center
        let styleCenter = CGFloat(-175.973)
        let styleHigh =  CGFloat(-175.973+100)
        let styleLow =  CGFloat(-175.973-100)
        
        
        switch(Int(arc4random_uniform(3))){
        case 0:
            selected.position.y = styleCenter
            break
        case 1:
            selected.position.y = styleHigh
            break
        case 2:
            selected.position.y = styleLow
            break
        default:
            break
        }
        
        
    }
    func manageGround(){
        //moving both alpha and beta
        groundAlpha.position.x-=2
        groundBeta.position.x-=2
        //exchange alpha and beta as they scroll
        if(groundBeta.position.x <= groundAnchorAlpha.x){
            groundAlpha.position.x = groundAnchorBeta.x
            //switch groundAlpha and groundBeta
            let tempGround = groundAlpha
            groundAlpha = groundBeta
            groundBeta = tempGround
            //redo pipes
            
        }
        
        
    }
}
