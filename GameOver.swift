//
//  GameOver.swift
//  Color Skip
//
//  Created by Shant Narkizian on 9/7/18.
//  Copyright © 2018 Shant Narkizian. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit
let localPlayer = GKLocalPlayer()

class GameOver: SKScene, GKGameCenterControllerDelegate {

    let default1 = UserDefaults()
    var highestScore = 1
    
    let restart_btn = SKSpriteNode(imageNamed: "restart")
    let back_btn = SKSpriteNode(imageNamed: "return")
    let gmc = SKLabelNode(fontNamed: "TArial-BoldMT")
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = .black
        
        //score label
        let score_label = SKLabelNode(fontNamed: "TArial-BoldMT")
        score_label.text = "\(score)"
        score_label.fontSize = 125
        score_label.position = CGPoint(x: 0, y: 115)
        score_label.zPosition = 1
        self.addChild(score_label)
        
        //leaderboard label
        gmc.text = "LEADERBOARDS"
        gmc.fontSize = 60
        gmc.position = CGPoint(x: 0, y: -500)
        gmc.zPosition = 1
        self.addChild(gmc)
        
        //get current highscore
        highestScore = default1.integer(forKey: "highest")
        
        //update highscore
        if score > highestScore{
            highestScore = score
            default1.set(highestScore, forKey: "highest")
        }
        
        //high score label
        let highestScore_label = SKLabelNode(fontNamed: "TArial-BoldMT")
        highestScore_label.text = "\(highestScore)"
        highestScore_label.fontSize = 125
        highestScore_label.position = CGPoint(x: 0, y: -95)
        highestScore_label.zPosition = 1
        self.addChild(highestScore_label)
        
        restart_btn.setScale(1)
        restart_btn.position = CGPoint(x: 0, y: -300)
        restart_btn.zPosition = 2
        self.addChild(restart_btn)
        print(restart_btn.position)
        
        back_btn.setScale(0.5)
        back_btn.position = CGPoint(x: -270, y: 570)
        back_btn.zPosition = 2
        self.addChild(back_btn)
        
        //animation for replay button
        let up = SKAction.scale(to: 1.2, duration: 1.0)
        let down = SKAction.scale(to: 1, duration: 1.0)
        let pulse = SKAction.sequence([up, down])
        let redo = SKAction.repeatForever(pulse)
        self.restart_btn.run(redo)
    
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let Point = touch.location(in: self)
            
            if restart_btn.contains(Point){
                gs = gameState.Playing
                let play = GameScene(size: CGSize(width: 1536, height: 2048))
                play.scaleMode = .aspectFill
                self.view?.presentScene(play)
            }
            
            if back_btn.contains(Point){
                gs = gameState.Main_Menu
                let play = GameScene(size: CGSize(width: 1536, height: 2048))
                play.scaleMode = .aspectFill
                self.view?.presentScene(play)
            }
            
            if gmc.contains(Point){
                highestScore = default1.integer(forKey: "highest")
                saveHS(number: highestScore)
                showLeader()
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func saveHS(number: Int){
        print("called save with", number)
        if GKLocalPlayer.localPlayer().isAuthenticated{
        
            let scoreReport = GKScore(leaderboardIdentifier: "CC")
            
            scoreReport.value = Int64(number)
            let scoreArray : [GKScore] = [scoreReport]
            
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }
    
    func showLeader(){
        let viewController = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        
        gc.gameCenterDelegate = self
        
        viewController?.present(gc, animated: true, completion: nil)
    }
    
}
