//
//  GameViewController.swift
//  Hornet Hunter
//
//  Created by Samsul Hoque on 7/28/20.
//  Copyright © 2020 HawkTech. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds

let banner: GADBannerView = {
    let banner = GADBannerView()
    //The next line is the REAL ad.
    banner.adUnitID = "ca-app-pub-9478712822460417/2723971381"
    //The next line is the test ad.
    //banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    banner.load(GADRequest())
    banner.tag = 100
    return banner
}()

class GameViewController: UIViewController, GADBannerViewDelegate
{
    var backgroundMusic = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        banner.isHidden = true
        banner.delegate = self
        banner.rootViewController = self
        view.addSubview(banner)
        
        //Music: "Infected Vibes" by Alejandro Magaña (A.M.) https://mixkit.co/free-stock-music/tag/videogame/
        let filePath = Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3")
        let audioNSURL = URL(fileURLWithPath: filePath!)
        
        do
        {
            backgroundMusic = try AVAudioPlayer(contentsOf: audioNSURL)
        }
        catch
        {
            return print("Cannot find audio file")
        }
        
        backgroundMusic.numberOfLoops = -1 //Loops forever
        backgroundMusic.play()
        
        let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
        
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        banner.frame = CGRect(x: 0, y: view.frame.size.height - 50, width: view.frame.size.width, height: 50).integral
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        banner.isHidden = false
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        banner.isHidden = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
