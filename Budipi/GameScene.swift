
import SpriteKit
import GameplayKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Point: \(score)"
        }
    }
    
    var gameTimer:Timer!
    var aliens = ["CoronaVirus1" , "CoronaVirus2" , "CoronaVirus3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0

    
    let motionMeneger = CMMotionManager()
    var xAccelerate:CGFloat = 0

    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint (x: 0, y: 1792)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        starfield.zPosition = -1
        
        
        player = SKSpriteNode(imageNamed: "Budipi")
        player.position = CGPoint(x: 450, y: 100)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Point: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = UIColor.blue
        scoreLabel.position = CGPoint (x: 100, y: 1200)
        score = 0
        
        self.addChild(scoreLabel)
        
        var timeInterval  = 0.85
        if UserDefaults.standard.bool(forKey: "Сложно") {
            timeInterval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionMeneger.accelerometerUpdateInterval = 0.2
        motionMeneger.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, _: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 40
             
        if player.position.x < 20 {
            player.position = CGPoint(x: 700, y: player.position.y)
        } else if player.position.x > 700 {
            player.position = CGPoint(x: 20, y: player.position.y)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody:SKPhysicsBody
        var bulletBody:SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        } else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        
        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
            
            
        }
        
    }
    
        
    
    
    func collisionElements(bulletNode:SKSpriteNode, alienNode:SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("rlaunch.wav", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        score += 1
    }
    
    @objc func addAlien() {
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: 700)
        let pos = CGFloat(randomPos.nextInt())
        alien.position = CGPoint(x: pos, y: 1800)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        
        let AnimDuration:TimeInterval = 7
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: AnimDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("flaunch.wav", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "bullett")
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        
        let AnimDuration:TimeInterval = 0.5
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: 2000 ), duration: AnimDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    
    func music() {
        
        self.run(SKAction.playSoundFileNamed("The Fall of Arcana.mp3", waitForCompletion: false))
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
