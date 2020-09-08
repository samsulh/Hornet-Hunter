//
//  MainMenuScene.swift
//  Hornet Hunter
//
//  Created by Samsul Hoque on 8/20/20.
//  Copyright © 2020 HawkTech. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene
{
    override func didMove(to view: SKView)
    {
        //Hide the ad during the MainMenuScene
        banner.isHidden = true
        banner.alpha = 0
        
        //Create the background
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        let formattedDate = format.string(from: date)
        
        let gameBy = SKLabelNode(fontNamed: "Arial")
        gameBy.text = "©\(formattedDate) HawkTech Industries"
        gameBy.fontSize = 50
        gameBy.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        gameBy.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.05)
        gameBy.zPosition = 1
        self.addChild(gameBy)
        
        let gameName1 = SKLabelNode(fontNamed: "KomikaAxis")
        gameName1.text = "Hornet"
        gameName1.fontSize = 150
        gameName1.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        gameName1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameName1.zPosition = 1
        self.addChild(gameName1)
        
        let gameName2 = SKLabelNode(fontNamed: "KomikaAxis")
        gameName2.text = "Hunter"
        gameName2.fontSize = 150
        gameName2.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        gameName2.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.625)
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        let startGame = SKLabelNode(fontNamed: "KomikaAxis")
        startGame.text = "Start Game"
        startGame.fontSize = 110
        startGame.fontColor = SKColor.init(red: 0, green: 0.25, blue: 0, alpha: 1)
        startGame.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.25)
        startGame.zPosition = 1
        startGame.name = "startButton"
        self.addChild(startGame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches
        {
            let pointOfTouch = touch.location(in: self)
            
            for nodeITapped in self.nodes(at: pointOfTouch)
            {
                if (nodeITapped.name == "startButton")
                {
                    let sceneToMoveTo = GameScene(size: self.size)
                    sceneToMoveTo.scaleMode = self.scaleMode
                    let myTransition = SKTransition.fade(withDuration: 0.5)
                    self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                }
            }
        }
    }
}
