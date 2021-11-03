//
//  GameViewController.swift
//  Budipi
//
//  Created by ILIA VORONKOV on 25.11.2020.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
class GameViewController: UIViewController {
    
    var player:AVAudioPlayer = AVAudioPlayer()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do
        {
            let audioPath = Bundle.main.path(forResource: "Acrana", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        
       catch
       {
        //PROCESS ERORR
       }
        let session = AVAudioSession.sharedInstance()
        
        do
        {
            try session.setCategory(AVAudioSession.Category.playback)
            
        }
        catch
        {
            
        }
        
        player.play() 
    
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
