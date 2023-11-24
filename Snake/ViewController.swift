//
//  ViewController.swift
//  Snake
//
//  Created by huge on 20/11/2023.
//

import UIKit



class ViewController: UIViewController {
    
    var moveTimer: Timer?
    
    var foodOnScreen: UIView?
    var difficultnessTimer: Timer?
    var speed = 0.5
    var isGameOver = false
    ///prevent two quick swipes
    ///set to true when user can swipe again
    var directionDebounce = true
    
    var currentDirection: Snake.Direction = .up
    
    var score = 0 {
        didSet {
            let stringedScore = String(score)
            scoreLabel.text = stringedScore
        }
    }
    
    ///do not set directly. just update score var
    lazy var scoreLabel: UILabel = {
        
        let score = UILabel(frame: .init(x: 0, y: 0, width: 110, height: 35))
        score.textAlignment = .center
        score.font = .boldSystemFont(ofSize: 30)
        score.textColor = .darkGray
        score.backgroundColor = .systemGray6
        score.layer.cornerRadius = 15
        score.alpha = 0.5
        score.center.x = view.center.x
        score.center.y = 100
        score.text = "0"
        return score
    }()
    
    lazy var gameArea: CGRect = {
        let rect = CGRect(x: 20, y: 60, width: view.frame.width - 40, height: view.frame.height - 100)
        return rect
    }()
    
    
    lazy var snake = Snake(view.center,superView: view)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(view.safeAreaInsets.top)
        
        configSwipeActions()
        
        setGameBounderies()
        
        addFood()
        
//        move(.up)
        debounceMove()
        
        view.addSubview(snake.head)
        
        view.addSubview(scoreLabel)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startOver)))
    }
    
    @objc func startOver() {
        //only if game over
        guard isGameOver == true else {return}
        
        //zero down speed
        self.speed = 0.5
        
        score = 0
        
        //remove all nodes
        snake.removeAllNodes()
        
        UIView.animate(withDuration: 0.3) {
            self.scoreLabel.transform = .init(scaleX: 1, y: 1)
            self.scoreLabel.center.y = 100
            //reset view
            self.view.backgroundColor = .white
            //relocate
            self.snake.head.center = self.view.center
        }
        
        //start moving
//        move(.up)
        moveTimer?.invalidate()
        debounceMove()
        snake.addTail(.up)
        //start moving
        isGameOver = false
    }
    
    func increaseDifficult() {
        speed *= 0.95
    }
    
    // MARK: - Handle touch
    
    func configSwipeActions() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
    }
    
    @objc func swipedUp(_ sender:UISwipeGestureRecognizer) {
        guard self.directionDebounce == true else {return}
        guard currentDirection != .down && currentDirection != .up else {return}
        currentDirection = .up
        self.directionDebounce = false
    }
    
    @objc func swipedDown(_ sender:UISwipeGestureRecognizer) {
        guard self.directionDebounce == true else {return}
        guard currentDirection != .up && currentDirection != .down else {return}
        currentDirection = .down
        self.directionDebounce = false
    }
    
    @objc func swipedLeft(_ sender:UISwipeGestureRecognizer) {
        guard self.directionDebounce == true else {return}
        guard currentDirection != .right && currentDirection != .left else {return}
        currentDirection = .left
        self.directionDebounce = false
    }
    
    @objc func swipedRight(_ sender:UISwipeGestureRecognizer) {
        guard self.directionDebounce == true else {return}
        guard currentDirection != .left && currentDirection != .right else {return}
        currentDirection = .right
        self.directionDebounce = false
    }
    
    func debounceMove() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: self.speed, repeats: false) { [weak self] timer in
            guard let self else {return}
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.6)
            
            //move
            self.snake.move(to: self.currentDirection)
            
            //if touched frame
            guard !self.shouldStop(self.snake) else {
                gameOver()
                return
            }
            
            //if ate food
            if let foodOnScreen {
                if snake.head.frame.intersects(foodOnScreen.frame) {
                    self.foodIsEaten(currentDirection)
                }
            }
            
            //if touched itself
            for (n,nodeFrame) in snake.frames.enumerated() where n != 0 {
                if snake.head.frame.intersects(nodeFrame) {
                    gameOver()
                    return
                }
            }
            
            //recuresive
            self.debounceMove()
            self.directionDebounce = true
        }
    }
    
    func foodIsEaten(_ direction:Snake.Direction) {
        self.foodOnScreen?.removeFromSuperview()
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1)
        addFood()
        score += 10
        snake.addTail(direction)
        self.increaseDifficult()
    }
    
    func gameOver() {
        self.moveTimer?.invalidate()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = .systemRed
            self.scoreLabel.transform = .init(scaleX: 3, y: 3)
            self.scoreLabel.center = self.view.center
        }
        isGameOver = true
    }
     
    // MARK: - Config UI
    
    func setGameBounderies() {
        let gameAreaView = UIView(frame: gameArea)
        gameAreaView.layer.borderWidth = 2
        gameAreaView.layer.borderColor = UIColor.red.withAlphaComponent(0.4).cgColor
        gameAreaView.isUserInteractionEnabled = false
        gameAreaView.backgroundColor = .clear
        view.addSubview(gameAreaView)
    }
    
    // MARK: - Logic funcs
    
    func shouldStop(_ snake:Snake) -> Bool {
        snake.head.center.y < 85 || //up
        snake.head.center.x > view.frame.width - 50 || // right
        snake.head.center.x < 40 || //left
        snake.head.center.y > view.frame.height - 45
    }
    
     
    func addFood() {
        let randomX = Int.random(in: 50...Int(view.frame.width - 50))
        let randomY = Int.random(in: 100...Int(view.frame.height - 50))
        let randomPointOnScreen: CGPoint = .init(x: randomX, y: randomY)
        
        let food = UIView(frame: .init(x: 0, y: 0, width: 7, height: 7))
        food.layer.cornerRadius = 7/2
        food.center = randomPointOnScreen
        food.backgroundColor = .systemRed
        self.foodOnScreen = food
        view.addSubview(food)
    }

}

