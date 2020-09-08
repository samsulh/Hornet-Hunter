//
//  GameOverScene.swift
//  Hornet Hunter
//
//  Created by Samsul Hoque on 8/19/20.
//  Copyright © 2020 HawkTech. All rights reserved.
//

import Foundation
import SpriteKit
import GoogleMobileAds

class GameOverScene: SKScene, GADBannerViewDelegate
{
    let restartLabel = SKLabelNode(fontNamed: "KomikaAxis")
    
    override func didMove(to view: SKView)
    {
        //Show the ad in the GameOverScene
        banner.isHidden = false
        banner.alpha = 1
        
        //Create the background
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "KomikaAxis")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 150
        gameOverLabel.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "KomikaAxis")
        scoreLabel.text = "Score: \(currentScore)"
        scoreLabel.fontSize = 110
        scoreLabel.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if (currentScore > highScoreNumber)
        {
            highScoreNumber = currentScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "KomikaAxis")
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 110
        highScoreLabel.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.45)
        self.addChild(highScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 80
        restartLabel.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch: AnyObject in touches
        {
            let pointOfTouch = touch.location(in: self)
            
            if (restartLabel.contains(pointOfTouch))
            {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
}
