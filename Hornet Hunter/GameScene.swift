//
//  GameScene.swift
//  Hornet Hunter
//
//  Created by Samsul Hoque on 7/28/20.
//  Copyright © 2020 HawkTech. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

var currentScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //Enumerator to store the three possible game states.
    enum gameState
    {
        case preGame
        case inGame
        case postGame
    }
    
    var currentGameState = gameState.inGame
    
    //Create the cannons
    let cannonOffUp = SKSpriteNode(imageNamed: "cannon-off-up")
    let cannonOnUp = SKSpriteNode(imageNamed: "cannon-on-up")
    var currentAngle: CGFloat = 0.0
    var cannonHeight: Float = 0.00
    
    //Sound effects can go here
    let cannonSound = SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    let zap = SKAction.playSoundFileNamed("zap.wav", waitForCompletion: false)
    let healthSound = SKAction.playSoundFileNamed("healthPlusSound.wav", waitForCompletion: false)
    
    let scoreLabel = SKLabelNode(fontNamed: "KomikaAxis")
    
    var currentLevel = 0
    
    var currentHealth = 5
    let healthMeter0 = SKSpriteNode(imageNamed: "health0Meter")
    let healthMeter1 = SKSpriteNode(imageNamed: "health1Meter")
    let healthMeter2 = SKSpriteNode(imageNamed: "health2Meter")
    let healthMeter3 = SKSpriteNode(imageNamed: "health3Meter")
    let healthMeter4 = SKSpriteNode(imageNamed: "health4Meter")
    let healthMeter5 = SKSpriteNode(imageNamed: "health5Meter")
    
    //Four physics categories. The reason why we don't explicitly have a 3 is because we can just add 1 and 2 to get 3.
    struct PhysicsCategories {
        static let None : UInt32 = 0          //Swift binary for 0
        static let Cannon : UInt32 = 0b1      //Swift binary for 1
        static let CannonBall : UInt32 = 0b10 //Swift binary for 2
        static let Hornet : UInt32 = 0b100    //Swift binary for 4
        static let Health : UInt32 = 0b1000   //Swift binary for 8
    }
    
    override func didMove(to view: SKView)
    {
        self.physicsWorld.contactDelegate = self
        
        //Hide the ad during the GameScene
        banner.isHidden = true
        banner.alpha = 0
        
        currentScore = 0
        
        //Create the background
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        //Setup the CannonOffUp
        cannonOffUp.setScale(3)
        cannonOffUp.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        cannonOffUp.zPosition = 2
        cannonOffUp.physicsBody = SKPhysicsBody(circleOfRadius: cannonOffUp.size.width/2)
        cannonOffUp.physicsBody!.affectedByGravity = false
        cannonOffUp.physicsBody!.categoryBitMask = PhysicsCategories.Cannon
        cannonOffUp.physicsBody!.collisionBitMask = PhysicsCategories.None
        cannonOffUp.physicsBody!.contactTestBitMask = PhysicsCategories.Hornet
        self.addChild(cannonOffUp)
        cannonHeight = Float(cannonOffUp.size.height/3)
        
        //Setup the CannonOnUp
        cannonOnUp.setScale(3)
        cannonOnUp.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        cannonOnUp.zPosition = 3
        cannonOnUp.alpha = 0
        self.addChild(cannonOnUp)
        
        startRotateCannons(rotateTime: 1)
        
        beginHornetAttack()
        
        beginHealth()
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.20, y: self.size.height - 2.5 * scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        healthMeter0.setScale(1)
        healthMeter0.position = CGPoint(x: self.size.width * 0.7, y: self.size.height - 1.1 * healthMeter0.frame.size.height)
        healthMeter0.zPosition = 100
        self.addChild(healthMeter0)
        
        healthMeter1.setScale(1)
        healthMeter1.position = CGPoint(x: self.size.width * 0.7, y: self.size.height - 1.1 * healthMeter1.frame.size.height)
        healthMeter1.zPosition = 101
        self.addChild(healthMeter1)
        
        healthMeter2.setScale(1)
        healthMeter2.position = CGPoint(x: self.size.width * 0.7, y: self.size.height - 1.1 * healthMeter2.frame.size.height)
        healthMeter2.zPosition = 101
        self.addChild(healthMeter2)
        
        healthMeter3.setScale(1)
        healthMeter3.position = CGPoint(x: self.size.width * 0.7, y: self.size.height - 1.1 * healthMeter3.frame.size.height)
        healthMeter3.zPosition = 101
        self.addChild(healthMeter3)
        
        healthMeter4.setScale(1)
        healthMeter4.position = CGPoint(x: self.size.width * 0.7, y: self.size.height - 1.1 * healthMeter4.frame.size.height)
        healthMeter4.zPosition = 101
        self.addChild(healthMeter4)
        
        healthMeter5.setScale(1)
        healthMeter5.position = CGPoint(x: self.size.width * 0.7, y: self.size.height - 1.1 * healthMeter5.frame.size.height)
        healthMeter5.zPosition = 101
        self.addChild(healthMeter5)
    }
    
    //This function runs in the background and gets called for every frame of the scene.
    override func update(_ currentTime: TimeInterval)
    {
        currentAngle = cannonOffUp.zRotation
        currentAngle = currentAngle + .pi / 2 + .pi / 24
    }
    
    func fireCannonBall(cannonDuration: TimeInterval)
    {
        let cannonBall = SKSpriteNode(imageNamed: "cannonBall")
        cannonBall.name = "CannonBall"
        cannonBall.setScale(0.75)
        cannonBall.position.x = CGFloat(cannonHeight) * cos(currentAngle) + cannonOffUp.position.x
        cannonBall.position.y = CGFloat(cannonHeight) * sin(currentAngle) + cannonOffUp.position.y
        cannonBall.zPosition = 1
        cannonBall.physicsBody = SKPhysicsBody(circleOfRadius: cannonBall.size.width/2)
        cannonBall.physicsBody!.affectedByGravity = false
        cannonBall.physicsBody!.categoryBitMask = PhysicsCategories.CannonBall
        cannonBall.physicsBody!.collisionBitMask = PhysicsCategories.None
        cannonBall.physicsBody!.contactTestBitMask = PhysicsCategories.Hornet
        self.addChild(cannonBall)
        
        let moveCannonBall = SKAction.moveBy(x: cos(currentAngle) * 2400, y: sin(currentAngle) * 2400, duration: cannonDuration)
        let deleteCannonBall = SKAction.removeFromParent()
        let cannonSequence = SKAction.sequence([cannonSound, moveCannonBall, deleteCannonBall])
        cannonBall.run(cannonSequence)
    }
    
    func spawnMurderHornet()
    {
        let hornet = SKSpriteNode(imageNamed: "hornet")
        hornet.name = "Hornet"
        hornet.setScale(2)
        let randomXPosition = CGFloat.random(in: 0 ... self.size.width)
        let topOrBottom = Int.random(in: 0 ... 1)
        if (topOrBottom == 0)
        {
            hornet.position.y = 0 - hornet.size.height
        }
        else
        {
            hornet.position.y = self.size.height + hornet.size.height
        }
        hornet.position.x = randomXPosition
        hornet.zPosition = 2
        hornet.physicsBody = SKPhysicsBody(circleOfRadius: hornet.size.width/5)
        hornet.physicsBody!.affectedByGravity = false
        hornet.physicsBody!.categoryBitMask = PhysicsCategories.Hornet
        hornet.physicsBody!.collisionBitMask = PhysicsCategories.None
        hornet.physicsBody!.contactTestBitMask = PhysicsCategories.Cannon | PhysicsCategories.CannonBall
        self.addChild(hornet)
        
        let moveHornet = SKAction.move(to: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5), duration: 8)
        let deleteHornet = SKAction.removeFromParent()
        let hornetSequence = SKAction.sequence([moveHornet, deleteHornet])
        if (currentGameState == gameState.inGame)
        {
            hornet.run(hornetSequence)
        }
        
        let dx = self.size.width * 0.5 - randomXPosition
        let dy = self.size.height * 0.5 - hornet.position.y
        let amountToRotate = atan2(dy, dx) + .pi / 2
        hornet.zRotation = amountToRotate
    }
    
    //Create the electric fence because Chumki said so
    func spawnElectricFence()
    {
        let fence = SKSpriteNode(imageNamed: "electric-fence-done")
        fence.setScale(3)
        fence.position.x = self.size.width/2
        fence.position.y = self.size.height/2
        fence.zPosition = 4
        fence.zRotation = CGFloat.random(in: 0 ... 2 * .pi)
        self.addChild(fence)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let delete = SKAction.removeFromParent()
        let fenceSequence = SKAction.sequence([zap, fadeIn, fadeOut, delete])
        fence.run(fenceSequence)
    }
    
    func spawnHealthPlus()
    {
        let healthPlus = SKSpriteNode(imageNamed: "health-plus")
        healthPlus.setScale(0.75)
        healthPlus.name = "HealthPlus"
        let randomXPosition = CGFloat.random(in: 0 ... self.size.width)
        let topOrBottom = Int.random(in: 0 ... 1)
        if (topOrBottom == 0)
        {
            healthPlus.position.y = 0 - healthPlus.size.height
        }
        else
        {
            healthPlus.position.y = self.size.height + healthPlus.size.height
        }
        healthPlus.position.x = randomXPosition
        healthPlus.zPosition = 1
        healthPlus.physicsBody = SKPhysicsBody(circleOfRadius: healthPlus.size.width/3)
        healthPlus.physicsBody!.affectedByGravity = false
        healthPlus.physicsBody!.categoryBitMask = PhysicsCategories.Health
        healthPlus.physicsBody!.collisionBitMask = PhysicsCategories.None
        healthPlus.physicsBody!.contactTestBitMask = PhysicsCategories.Cannon | PhysicsCategories.CannonBall
        self.addChild(healthPlus)
        
        let moveHealthPlus = SKAction.move(to: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5), duration: 10)
        let deleteHealthPlus = SKAction.removeFromParent()
        let healthPlusSequence = SKAction.sequence([moveHealthPlus, deleteHealthPlus])
        if (currentGameState == gameState.inGame)
        {
            healthPlus.run(healthPlusSequence)
        }
    }
    
    func spawnHealthPlusAnimation()
    {
        let healthAnimation = SKSpriteNode(imageNamed: "healthAnimation")
        healthAnimation.setScale(3)
        healthAnimation.position.x = self.size.width/2
        healthAnimation.position.y = self.size.height/2
        healthAnimation.zPosition = 4
        self.addChild(healthAnimation)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.35)
        let fadeOut = SKAction.fadeOut(withDuration: 0.35)
        let delete = SKAction.removeFromParent()
        let healthAnimateSequence = SKAction.sequence([healthSound, fadeIn, fadeOut, delete])
        healthAnimation.run(healthAnimateSequence)
    }
    
    func beginHealth()
    {
        let healthPause = Int.random(in: 15 ... 20)
        
        let spawn = SKAction.run(spawnHealthPlus)
        let waitToSpawn = SKAction.wait(forDuration: TimeInterval(healthPause))
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningHealthPlus")
    }
    
    func beginHornetAttack()
    {
        currentLevel += 1
        
        if (self.action(forKey: "spawningHornets") != nil)
        {
            self.removeAction(forKey: "spawningHornets")
        }
        
        var levelDuration = NSTimeIntervalSince1970
        
        switch currentLevel {
        case 1:
            levelDuration = 2.2
        case 2:
            levelDuration = 1.9
        case 3:
            levelDuration = 1.6
        case 4:
            levelDuration = 1.3
        case 5:
            levelDuration = 1.0
        default:
            levelDuration = 1.0
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnMurderHornet)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningHornets")
    }
    
    func spawnExplosion(spawnPosition: CGPoint)
    {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 5
        explosion.setScale(1)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func spawnMegaExplosion()
    {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position.x = self.size.width/2
        explosion.position.y = self.size.height/2
        explosion.zPosition = 5
        explosion.setScale(2)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 2, duration: 0.25)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func startRotateCannons(rotateTime: TimeInterval)
    {
        let rotateCannonAction = SKAction.rotate(byAngle: 0.8 * .pi, duration: rotateTime)
        let rotate4ever = SKAction.repeatForever(rotateCannonAction)
        cannonOffUp.run(rotate4ever)
        cannonOnUp.run(rotate4ever)
    }
    
    func addScore()
    {
        currentScore += 1
        scoreLabel.text = "Score: \(currentScore)"
        
        if (currentScore == 10 || currentScore == 20 || currentScore == 30 || currentScore == 40)
        {
            beginHornetAttack()
        }
        
        startRotateCannons(rotateTime: 10)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (currentGameState == gameState.inGame)
        {
            cannonOffUp.alpha = 0
            cannonOnUp.alpha = 1
            var theDuration: TimeInterval = 6
            
            self.view!.isUserInteractionEnabled = false
            var minWaitBetweenShots = 0.20
            if (currentScore < 10)
            {
                minWaitBetweenShots = 0.20
                theDuration = 3.5
            }
            else if (currentScore < 20)
            {
                minWaitBetweenShots = 0.18
                theDuration = 3.0
            }
            else if (currentScore < 30)
            {
                minWaitBetweenShots = 0.16
                theDuration = 2.5
            }
            else if (currentScore < 40)
            {
                minWaitBetweenShots = 0.16
                theDuration = 2.0
            }
            else
            {
                minWaitBetweenShots = 0.16
                theDuration = 1.5
            }
            fireCannonBall(cannonDuration: theDuration)
            DispatchQueue.main.asyncAfter(deadline: .now() + minWaitBetweenShots)
            {
                self.view!.isUserInteractionEnabled = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        cannonOffUp.alpha = 1
        cannonOnUp.alpha = 0
    }
    
    func gameOver()
    {
        currentGameState = gameState.postGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "CannonBall")
        {
            (bullet, stop) in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Hornet")
        {
            (enemy, stop) in
            enemy.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "HealthPlus")
        {
            (enemy, stop) in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene()
    {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        //Putting BodyA and BodyB in numerical order
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else
        {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        //If a health+ hits the cannon, do this
        if (body1.categoryBitMask == PhysicsCategories.Cannon && body2.categoryBitMask == PhysicsCategories.Health)
        {
            if (currentHealth != 5)
            {
                spawnHealthPlusAnimation()
            }
            body2.node?.removeFromParent()
            if (currentHealth == 1)
            {
                healthMeter2.alpha = 1
                currentHealth += 1
            }
            else if (currentHealth == 2)
            {
                healthMeter3.alpha = 1
                currentHealth += 1
            }
            else if (currentHealth == 3)
            {
                healthMeter4.alpha = 1
                currentHealth += 1
            }
            else if (currentHealth == 4)
            {
                healthMeter5.alpha = 1
                currentHealth += 1
            }
        }
        
        //If a cannonball hits a hornet, do this
        var body2YPos: CGFloat
        if (body2.node?.position.y != nil)
        {
            body2YPos = (body2.node?.position.y)!
        }
        else
        {
            body2YPos = self.size.height/2
        }
        if body1.categoryBitMask == PhysicsCategories.CannonBall && body2.categoryBitMask == PhysicsCategories.Hornet && body2YPos < self.size.height + 30 && body2YPos > -100
        {
            addScore()
            
            if body2.node != nil
            {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        //If a cannonball hits a health+, do this
        if (body1.categoryBitMask == PhysicsCategories.CannonBall && body2.categoryBitMask == PhysicsCategories.Health && (body2.node?.position.y)! < self.size.height && (body2.node?.position.y)! > 0)
        {
            if (body2.node != nil)
            {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        //If a hornet hits the cannon, do this
        if (body1.categoryBitMask == PhysicsCategories.Cannon && body2.categoryBitMask == PhysicsCategories.Hornet)
        {
            spawnElectricFence()
            body2.node?.removeFromParent()
            currentHealth -= 1
            if (currentHealth == 4)
            {
                healthMeter5.alpha = 0
            }
            else if (currentHealth == 3)
            {
                healthMeter4.alpha = 0
            }
            else if (currentHealth == 2)
            {
                healthMeter3.alpha = 0
            }
            else if (currentHealth == 1)
            {
                healthMeter2.alpha = 0
            }
            else if (currentHealth == 0)
            {
                healthMeter1.alpha = 0
                spawnMegaExplosion()
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                gameOver()
            }
        }
    }
}
