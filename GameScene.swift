//
//  GameScene.swift
//  Color Skip
//
//  Created by Shant Narkizian on 9/6/18.
//  Copyright © 2018 Shant Narkizian. All rights reserved.
//

import SpriteKit
import GameplayKit

//global variables
var score = 0
var level = 0
var bar_der: Float = 3
var one = 1

//state of game
enum gameState{
    case Main_Menu
    case Playing
    case Game_Over
}

var gs = gameState.Main_Menu

class GameScene: SKScene, SKPhysicsContactDelegate {

    let ball = SKShapeNode(circleOfRadius: 40)
    let score_label = SKLabelNode(fontNamed: "TArial-BoldMT")
    let start_label = SKLabelNode(fontNamed: "TArial-BoldMT")
    let title1 = SKLabelNode(fontNamed: "TArial-BoldMT")
    let title2 = SKLabelNode(fontNamed: "TArial-BoldMT")
    let highScore_label = SKLabelNode(fontNamed: "TArial-BoldMT")
    let highestScore_label = SKLabelNode(fontNamed: "TArial-BoldMT")
    
    var gameArea: CGRect
    var temp_time: Float = 1
    
    let star_sound = SKAction.playSoundFileNamed("coin-drop-4.mp3", waitForCompletion: false)
    let game_sound = SKAction.playSoundFileNamed("game_music.mp3", waitForCompletion: true)
    
    //play background music
    let dictToSend: [String: String] = ["fileToPlay": "game_music" ]
    
    struct obj{
        static let None: UInt32 = 0
        static let ball: UInt32 = 0b1
        static let bar1: UInt32 = 0b10
        static let bar2: UInt32 = 0b11
        static let bar3: UInt32 = 0b100
        static let bar4: UInt32 = 0b101
        static let star: UInt32 = 0b110
    }
    
    //manages frame size of device
    override init(size: CGSize) {
        
        var maxAR: CGFloat = 16.0/9.0
        if UIScreen.main.nativeBounds.height == 2436{
            maxAR = 812.0/375.0 //for iphone X
        }else{
            maxAR = 16.0/9.0 //for all other iphones
        }
        
        let max_width = size.height / maxAR
        let margins = (size.width - max_width) / 2
        gameArea = CGRect(x: margins, y: 0, width: max_width, height: size.height)

        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //move to view
    override func didMove(to view: SKView) {
        
       authenticateLocalPlayer()
        
       NotificationCenter.default.post(name: Notification.Name(rawValue: "PlayBackgroundSound"), object: self, userInfo:dictToSend) //posts the notification

        //reset score
        score = 0
        if gs == gameState.Main_Menu{
            self.physicsWorld.contactDelegate = self
            let background = SKSpriteNode(imageNamed: "back")
            background.size = self.size
            background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            background.zPosition = 0
            self.addChild(background)
            
            ball.physicsBody = SKPhysicsBody(circleOfRadius: 30)
            ball.physicsBody!.affectedByGravity = false
            ball.physicsBody!.categoryBitMask = obj.ball
            ball.physicsBody!.collisionBitMask = obj.None
            
            start_label.text = "TAP TO BEGIN"
            start_label.fontColor = .green
            start_label.fontSize = 100
            start_label.zPosition = 1
            start_label.position = CGPoint(x: (self.size.width / 2) , y: self.size.height / 2)
            self.addChild(start_label)
            
            //animation for begin button
            let up = SKAction.scale(to: 1.2, duration: 1.0)
            let down = SKAction.scale(to: 1, duration: 1.0)
            let pulse = SKAction.sequence([up, down])
            let redo = SKAction.repeatForever(pulse)
            self.start_label.run(redo)
            
            title1.text = "COLOR"
            title1.fontSize = 150
            title1.zPosition = 1
            title1.position = CGPoint(x: (self.size.width / 2) , y: self.size.height * 0.90)
            self.addChild(title1)
            
            title2.text = "CLIMBER"
            title2.fontSize = 150
            title2.zPosition = 1
            title2.position = CGPoint(x: (self.size.width / 2) , y: self.size.height * 0.82)
            self.addChild(title2)
            
            //high score label
            highScore_label.text = "BEST SCORE:"
            highScore_label.fontSize = 60
            highScore_label.position = CGPoint(x: (self.size.width / 2) , y: self.size.height / 5)
            highScore_label.zPosition = 1
            self.addChild(highScore_label)
            
            //high score
            let default1 = UserDefaults()
            let highestScore = default1.integer(forKey: "highest")
            highestScore_label.text = "\(highestScore)"
            highestScore_label.fontSize = 125
            highestScore_label.position = CGPoint(x: (self.size.width / 2) , y: self.size.height / 7)
            highestScore_label.zPosition = 1
            self.addChild(highestScore_label)
            
        }else if gs == gameState.Playing{
            
            self.physicsWorld.contactDelegate = self
            
            let background = SKSpriteNode(imageNamed: "back")
            background.size = self.size
            background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            background.zPosition = 0
            self.addChild(background)
            
            ball.physicsBody = SKPhysicsBody(circleOfRadius: 30)
            ball.physicsBody!.affectedByGravity = false
            ball.physicsBody!.categoryBitMask = obj.ball
            ball.physicsBody!.collisionBitMask = obj.None
            
            start_game()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gs == gameState.Main_Menu{
            start_game()
        }
        gs = gameState.Playing
    }
    
    func start_game(){
        gs = gameState.Playing
        bar_der = 3
        temp_time = 1
        level = 1
        //fade out label and title
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()
        let seq = SKAction.sequence([fadeOut, delete])
        start_label.run(seq)
        title1.run(seq)
        title2.run(seq)
        highScore_label.run(seq)
        highestScore_label.run(seq)
        
        //add score
        score_label.text = "Score: 0"
        score_label.fontSize = 70
        score_label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        score_label.position = CGPoint(x: (self.size.width * 0.20) , y: self.size.height + 10)
        score_label.zPosition = 3
        self.addChild(score_label)
        
        let move_down = SKAction.moveTo(y: self.size.height * 0.93, duration: 0.2)
        score_label.run(move_down)
        
        //start game going
        addBall()
        spawnBars()
    }
    
    func increaseScore(){
        score += 1
        score_label.text = "Score: \(score)"
        
        if score == 50 || score == 100 || score == 150{
            bar_der -= 0.5
            spawnBars()
        }
    }
    
    func addBall(){
        ball.fillColor = .blue
        ball.strokeColor = ball.fillColor
        ball.position = CGPoint(x: self.size.width / 2, y: 500)
        ball.zPosition = 1
        self.addChild(ball)
    }

    //continuously calls addBar()
    func spawnBars(){
        
        level += 1
        
        //stop action
        if self.action(forKey: "spawning") != nil{
            self.removeAction(forKey: "spawning")
        }

        var time = TimeInterval()

        //make bars spawn faster
        switch level {
            case 1:
                time = 0.3
            case 2:
                time = 0.3
            case 3:
                time = 0.25
            case 4:
                time = 0.2
            case 5:
                time = 0.15
            default:
                time = 0.15
        }
        
        let spawn_bar = SKAction.run(addBar)
        let spawn_star = SKAction.run(addStar)
        let pause = SKAction.wait(forDuration: time * 2) //0.6
        let pause_half = SKAction.wait(forDuration: time) //0.3
        let sequence = SKAction.sequence([spawn_bar, pause, spawn_bar, pause, spawn_bar, pause_half, spawn_star, pause_half])
 
        let repeat_f = SKAction.repeatForever(sequence)
        
        self.run(SKAction.wait(forDuration: TimeInterval(temp_time)), completion: {self.run(repeat_f, withKey: "spawning")})
        print("WAITING", temp_time)
        
    }
    
    func addStar(){
        let screen_len = gameArea.maxX - gameArea.minX
        let star = SKSpriteNode(imageNamed: "star")
        star.name = "Star"
        star.setScale(0.11)
        star.zPosition = 1
        
        let max = screen_len - 50
        let min = gameArea.minX + 50
        
        let rand = Int(arc4random_uniform(UInt32(max)) + UInt32(min))
        
        star.position = CGPoint(x: CGFloat(rand), y: self.size.height * 1.2)
        star.physicsBody = SKPhysicsBody(rectangleOf: star.size)
        star.physicsBody!.affectedByGravity = false
        star.physicsBody!.categoryBitMask = obj.star
        star.physicsBody!.collisionBitMask = obj.None
        star.physicsBody!.contactTestBitMask = obj.ball
        
        self.addChild(star)
        
        //animation to make star pulse
        let up = SKAction.scale(to: 0.13, duration: 1.0)
        let down = SKAction.scale(to: 0.10, duration: 1.0)
        let pulse = SKAction.sequence([up, down])
        let redo = SKAction.repeatForever(pulse)
        star.run(redo)
        
        let end = CGPoint(x: CGFloat(rand), y: -self.size.height * 0.2)
        let moveStar = SKAction.move(to: end, duration: TimeInterval(bar_der))
        let deleteStar = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveStar, deleteStar])
        star.run(sequence)

    }
    
    func addBar(){
        let screen_len = gameArea.maxX - gameArea.minX
        let start_screen = gameArea.minX
        let quarter_len = screen_len / 4
        let over_screen = self.size.height * 1.2
        let under_screen = -self.size.height * 0.2
        
        //randomize the positions
        let bar1 = SKSpriteNode(imageNamed: "yellow_line")
        bar1.name = "Bar"
        bar1.setScale(1)
        bar1.size = CGSize(width: quarter_len, height: 30)
        bar1.zPosition = 1
        
        
        let bar2 = SKSpriteNode(imageNamed: "red_line")
        bar2.name = "Bar"
        bar2.setScale(1)
        bar2.size = CGSize(width: quarter_len, height: 30)
        bar2.zPosition = 1
        
        let bar3 = SKSpriteNode(imageNamed: "blue_line")
        bar3.name = "Bar"
        bar3.setScale(1)
        bar3.size = CGSize(width: quarter_len, height: 30)
        bar3.zPosition = 1
        
        let bar4 = SKSpriteNode(imageNamed: "green_line")
        bar4.name = "Bar"
        bar4.setScale(1)
        bar4.size = CGSize(width: quarter_len, height: 30)
        bar4.zPosition = 1
        
        
        //all posibile positions 0..3
        var positions_start = [CGPoint(x: start_screen + (quarter_len / 2), y: over_screen), CGPoint(x: start_screen + (quarter_len / 2) + bar1.size.width, y: over_screen), CGPoint(x: start_screen + (quarter_len / 2) + (bar1.size.width * 2), y: over_screen), CGPoint(x: start_screen + (quarter_len / 2) + (bar1.size.width * 3), y: over_screen)]
        
        var positions_end = [CGPoint(x: start_screen + (quarter_len / 2), y: under_screen), CGPoint(x: start_screen + (quarter_len / 2) + bar1.size.width, y: under_screen), CGPoint(x: start_screen + (quarter_len / 2) + (bar1.size.width * 2), y: under_screen), CGPoint(x: start_screen + (quarter_len / 2) + (bar1.size.width * 3), y: under_screen)]
        
        //randomize positions
        var rand_num = Int(arc4random_uniform(4) + 0)
        
        //animation
        bar1.position = positions_start[rand_num]
        var end = positions_end[rand_num]
        var moveBar = SKAction.move(to: end, duration: TimeInterval(bar_der)) //3
        let deleteBar = SKAction.removeFromParent()
        var sequence = SKAction.sequence([moveBar, deleteBar])
        bar1.run(sequence)
        
        //remove position
        positions_start.remove(at: rand_num)
        positions_end.remove(at: rand_num)
        rand_num = Int(arc4random_uniform(3) + 0)
        
        bar2.position = positions_start[rand_num]
        end = positions_end[rand_num]
        moveBar = SKAction.move(to: end, duration: TimeInterval(bar_der)) //3
        sequence = SKAction.sequence([moveBar, deleteBar])
        bar2.run(sequence)
        
        //remove position
        positions_start.remove(at: rand_num)
        positions_end.remove(at: rand_num)
        rand_num = Int(arc4random_uniform(2) + 0)
        
        bar3.position = positions_start[rand_num]
        end = positions_end[rand_num]
        moveBar = SKAction.move(to: end, duration: TimeInterval(bar_der))//3
        sequence = SKAction.sequence([moveBar, deleteBar])
        bar3.run(sequence)
        
        //remove position
        positions_start.remove(at: rand_num)
        positions_end.remove(at: rand_num)
        
        bar4.position = positions_start[0]
        end = positions_end[0]
        moveBar = SKAction.move(to: end, duration: TimeInterval(bar_der)) //3
        sequence = SKAction.sequence([moveBar, deleteBar])
        bar4.run(sequence)
        
        //physics collison detection
        bar1.physicsBody = SKPhysicsBody(rectangleOf: bar1.size)
        bar1.physicsBody!.affectedByGravity = false
        bar1.physicsBody!.categoryBitMask = obj.bar1
        bar1.physicsBody!.collisionBitMask = obj.None
        bar1.physicsBody!.contactTestBitMask = obj.ball
        
        bar2.physicsBody = SKPhysicsBody(rectangleOf: bar2.size)
        bar2.physicsBody!.affectedByGravity = false
        bar2.physicsBody!.categoryBitMask = obj.bar2
        bar2.physicsBody!.collisionBitMask = obj.None
        bar2.physicsBody!.contactTestBitMask = obj.ball
        
        bar3.physicsBody = SKPhysicsBody(rectangleOf: bar3.size)
        bar3.physicsBody!.affectedByGravity = false
        bar3.physicsBody!.categoryBitMask = obj.bar3
        bar3.physicsBody!.collisionBitMask = obj.None
        bar3.physicsBody!.contactTestBitMask = obj.ball
        
        bar4.physicsBody = SKPhysicsBody(rectangleOf: bar4.size)
        bar4.physicsBody!.affectedByGravity = false
        bar4.physicsBody!.categoryBitMask = obj.bar4
        bar4.physicsBody!.collisionBitMask = obj.None
        bar4.physicsBody!.contactTestBitMask = obj.ball
        
        self.addChild(bar1)
        self.addChild(bar2)
        self.addChild(bar3)
        self.addChild(bar4)
        
    }
    
    //handle collisons
    func didBegin(_ contact: SKPhysicsContact) {
        var obj1 = SKPhysicsBody()
        var obj2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            obj1 = contact.bodyA
            obj2 = contact.bodyB
        }else{
            obj1 = contact.bodyB
            obj2 = contact.bodyA
        }
        
        //player has hit star
        if obj1.categoryBitMask == obj.ball && obj2.categoryBitMask == obj.star{
            increaseScore()
            increaseScore()
            self.run(star_sound)
            obj2.node?.removeFromParent()
        }
        
        if (obj1.categoryBitMask == obj.ball && obj2.categoryBitMask == obj.bar3){
            increaseScore()
        }
        
        //Game Over
        if (obj1.categoryBitMask == obj.ball && obj2.categoryBitMask == obj.bar1) || (obj1.categoryBitMask == obj.ball && obj2.categoryBitMask == obj.bar2) || (obj1.categoryBitMask == obj.ball && obj2.categoryBitMask == obj.bar4){
            Game_lost()
        }
    }
    
    //moves to next scene
    func Game_lost(){
        
        gs = gameState.Game_Over
        self.removeAllActions()

        self.enumerateChildNodes(withName: "Bar"){
            bar1, stop in
            bar1.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Star"){
            star, stop in
            star.removeAllActions()
        }
        
        let changeScene = SKAction.run(nextScene)
        let pause = SKAction.wait(forDuration: 1.3)
        let sequence = SKAction.sequence([pause, changeScene])
        self.run(sequence)
        
    }
     
    func nextScene(){
        let GG = GameOver(fileNamed: "GameOver")
        GG?.scaleMode = .aspectFill
        self.view?.presentScene(GG!)
    }
    
    //authenticate the player
    func authenticateLocalPlayer(){
        //let localPlayer = GKLocalPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil && localPlayer.isAuthenticated) {
                let vc: UIViewController = self.view!.window!.rootViewController!
                vc.present(viewController!, animated: true, completion: nil)
            }else{
                print((localPlayer.isAuthenticated))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let start = touch.location(in: self)
            let fin = touch.previousLocation(in: self)
            let dist = start.x - fin.x
            
            //scale distance
            if gs == gameState.Playing{
                ball.position.x += (dist )//* 1.5)
               
                //keeps ball in screen
                if ball.position.x > gameArea.maxX - 40{ //radius of ball = 40
                    ball.position.x = gameArea.maxX - 40
                }else if ball.position.x < gameArea.minX + 40{
                    ball.position.x = gameArea.minX + 40
                }
            }
            
        }
    }
}
