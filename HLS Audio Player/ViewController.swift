//
//  ViewController.swift
//  HLS Audio Player
//
//  Created by nk on 11/18/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit
import AVFoundation

enum State {
    case uninitialized
    case fetching
    case playing
    case paused
    case completed
}

class ViewController: UIViewController {
    
    let throwingThreshold: CGFloat = 1000
    let throwingVelocityPadding: CGFloat = 1
    
    var state: State = .uninitialized {
        didSet {
            circlePlayer.state = state
        }
    }
    
    @IBOutlet var circlePlayer: CirclePlayer!
    
    var player: AVPlayer!
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var pushBehavior: UIPushBehavior!
    var snapBehaviour: UISnapBehavior!
    var collision: UICollisionBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    var xOFFset: CGFloat!
    var yOFFset: CGFloat!
    
    var panGesture: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        circlePlayer.button.addTarget(self, action: #selector(actionPerformed(_:)), for: .touchUpInside)
        circlePlayer.progress = 0.0
        circlePlayer.state = .uninitialized
        circlePlayer.frame = CGRect(x: 0, y: 0, width: 125, height: 125)
        circlePlayer.center = view.center
        
        // Instantiates the animator
        animator = UIDynamicAnimator(referenceView: view)
        
        // Instantiates the Gravity Behavior and assigns the circle player to it
        gravity = UIGravityBehavior(items: [circlePlayer])
        
        // Instantiates the Collision Behavior and assigns the circle player to it
        collision = UICollisionBehavior(items: [circlePlayer])
        collision.translatesReferenceBoundsIntoBoundary = true
        
        //animator.addBehavior(gravity)
        animator.addBehavior(collision)
        
        // Instantiates the Pan Gesture Recognizers and adds it to the circle player instance
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panning(_:)))
        circlePlayer.addGestureRecognizer(panGesture)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func actionPerformed(_ sender: Any) {

        switch state {
        case .uninitialized:
            self.state = .fetching
            fetchAudio()
        case .playing:
            // pause
            player.pause()
            self.state = .paused
        case .paused:
            // resume
            player.play()
            self.state = .playing
        case .fetching, .completed:
            break
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @objc func panning(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)
        let touchLocation = recognizer.location(in: circlePlayer)
        
        let velocity = recognizer.velocity(in: view)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        
        if magnitude > throwingThreshold && recognizer.state == .ended {
            
            animator.removeAllBehaviors()
            
            let pushBehavior = UIPushBehavior(items: [circlePlayer], mode: .instantaneous)
            let direction = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
            pushBehavior.pushDirection = direction
            
            print(direction.angle)
            
            pushBehavior.magnitude = magnitude / throwingVelocityPadding
            self.pushBehavior = pushBehavior

            animator.addBehavior(collision)
            animator.addBehavior(pushBehavior)
            // detect edge to snap
            let snapPoint = screenEdgeDirected(by: direction.angle, from: location)
            
            // snap to appropriate edge
            snapBehaviour = UISnapBehavior(item: circlePlayer, snapTo: normalizedCenter(snapPoint))
            
            animator.removeBehavior(pushBehavior)
            animator.addBehavior(snapBehaviour)
            
            
        } else {
            
            switch recognizer.state {
                
            case .began:
                xOFFset = touchLocation.x - circlePlayer.bounds.midX
                yOFFset = touchLocation.y - circlePlayer.bounds.midY
            case .changed:
                animator.removeAllBehaviors()
                var newCenter = CGPoint(x: location.x - xOFFset, y: location.y - yOFFset)
                let midX = circlePlayer.bounds.midX
                let midY = circlePlayer.bounds.midY
                
                let leftSide = newCenter.x - midX
                let rightSide = newCenter.x + midX
                let top = newCenter.y - midY
                let bottom = newCenter.y + midY
                
                if leftSide < 0 { newCenter.x = 0 + midX}
                if rightSide > view.bounds.width { newCenter.x = view.bounds.width - midX }
                if top < 0 { newCenter.y = 0 + midY }
                if bottom > view.bounds.height { newCenter.y = view.bounds.height - midY }
                
                circlePlayer.center = newCenter
            case .ended:
                animator.removeAllBehaviors()
                snapBehaviour = UISnapBehavior(item: circlePlayer, snapTo: circlePlayer.center)
                animator.addBehavior(snapBehaviour)
            default:
                break
            }
        }
    }
    
    /// returns center location to fit view withing screen bounds
    func normalizedCenter(_ center: CGPoint) -> CGPoint {
        let midX = circlePlayer.bounds.midX
        let midY = circlePlayer.bounds.midY
        
        var newCenter = center
        
        let leftSide = newCenter.x - midX
        let rightSide = newCenter.x + midX
        let top = newCenter.y - midY
        let bottom = newCenter.y + midY
        
        if leftSide < 0 { newCenter.x = 0 + midX}
        if rightSide > view.bounds.width { newCenter.x = view.bounds.width - midX }
        if top < 0 { newCenter.y = 0 + midY }
        if bottom > view.bounds.height { newCenter.y = view.bounds.height - midY }
        
        return newCenter
    }
    
    func fetchAudio() {
        DispatchQueue.global().async {
            let service = ConcurrentAudioFetch()
            //service.convert()
            service.fetchAudio(completion: { (audioURL) in
                DispatchQueue.main.async {
                    if let audioURL = audioURL {
                        self.player = AVPlayer(url: audioURL)
                        self.player.play()
                    }
                    self.state = .playing
                }
            }) { (progress) in
                DispatchQueue.main.async {
                    self.circlePlayer.progress = progress
                }
            }
        }
    }
    
    enum ScreenSquare {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    func screenSquare(at location: CGPoint) -> ScreenSquare {
        
        let squareSize = CGSize(width: view.bounds.width/2, height: view.bounds.height/2)
        let topLeftSquareOrigin = CGPoint(x: 0, y: 0)
        let topRightSquareOrigin = CGPoint(x: squareSize.width, y: 0)
        let bottomLeftSquareOrigin = CGPoint(x: 0, y: squareSize.height)
        let bottomRightSquareOrigin = CGPoint(x: squareSize.width, y: squareSize.height)
        
        let topLeftSquare = CGRect(origin: topLeftSquareOrigin, size: squareSize)
        let topRightSquare = CGRect(origin: topRightSquareOrigin, size: squareSize)
        let bottomLeftSquare = CGRect(origin: bottomLeftSquareOrigin, size: squareSize)
        let bottomRightSquare = CGRect(origin: bottomRightSquareOrigin, size: squareSize)
        
        if topLeftSquare.contains(location) {
            return .topLeft
        } else if topRightSquare.contains(location) {
            return .topRight
        } else if bottomLeftSquare.contains(location) {
            return .bottomLeft
        } else {
            return .bottomRight
        }
    }
    
    func edge(for screenSquare: ScreenSquare) -> CGPoint {
        switch screenSquare {
        case .topLeft:
            return CGPoint(x: 0, y: 0)
        case .topRight:
            return CGPoint(x: view.bounds.width, y: 0)
        case .bottomLeft:
            return CGPoint(x: 0, y: view.bounds.height)
        case .bottomRight:
            return CGPoint(x: view.bounds.width, y: view.bounds.height)
        }
    }
    
    func screenEdgeDirected(by angle: CGFloat, from location: CGPoint) -> CGPoint {
        
        let currentSquare = screenSquare(at: location)
        
        switch (currentSquare, angle) {
            /// topLeft
        case (.topLeft, 180), (.topLeft, (-179)...(-91)),
             (.topRight, 180),
             (.bottomLeft, (-135)...(-90)),
             (.bottomRight, (-160)...(-120)):
            return edge(for: .topLeft)
            /// topRight
        case (.topLeft, 0),
             (.topRight, (-90)...0),
             (.bottomLeft, (-60)...(-30)),
             (.bottomRight, -90):
            return edge(for: .topRight)
            /// bottomLeft
        case (.topLeft, 90),
             (.topRight, 120...160),
             (.bottomLeft, 90...180),
             (.bottomRight, 0):
            return edge(for: .bottomLeft)
            /// bottomRight
        case (.topLeft, 45),
             (.topRight, 90),
             (.bottomLeft, 0),
             (.bottomRight, (-90)...0):
            return edge(for: .bottomRight)
            /// return initial by default
        default:
            return edge(for: currentSquare)
        }
    }
}
