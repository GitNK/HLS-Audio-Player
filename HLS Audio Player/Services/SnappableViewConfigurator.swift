//
//  SnappableViewConfigurator.swift
//  HLS Audio Player
//
//  Created by Nikita Gromadskyi on 11/21/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit

class SnappableViewConfigurator {
    
    let throwingThreshold: CGFloat = 1000
    let throwingVelocityPadding: CGFloat = 50
    
    weak var snappingView: UIView!
    weak var parent: UIView!
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var pushBehavior: UIPushBehavior!
    var snapBehaviour: UISnapBehavior!
    var collision: UICollisionBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    var xOFFset: CGFloat!
    var yOFFset: CGFloat!
    var panGesture: UIPanGestureRecognizer!
    
    func addSnapping(for view: UIView, parent: UIView) {
        
        self.snappingView = view
        self.parent = parent
        
        // Instantiates the animator
        animator = UIDynamicAnimator(referenceView: parent)
        
        // Instantiates the Gravity Behavior and assigns the circle player to it
        gravity = UIGravityBehavior(items: [snappingView])
        
        // Instantiates the Collision Behavior and assigns the circle player to it
        collision = UICollisionBehavior(items: [snappingView])
        collision.translatesReferenceBoundsIntoBoundary = true
        
        //animator.addBehavior(gravity)
        animator.addBehavior(collision)
        
        // Instantiates the Pan Gesture Recognizers and adds it to the circle player instance
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panning(_:)))
        snappingView.addGestureRecognizer(panGesture)
        
    }
    
    func removeSnapping() {
        animator.removeAllBehaviors()
        animator = nil
        gravity = nil
        pushBehavior = nil
        snapBehaviour = nil
        collision = nil
        attachmentBehavior = nil
        xOFFset = nil
        yOFFset = nil
        panGesture = nil
    }
    
    @objc func panning(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: parent)
        let touchLocation = recognizer.location(in: snappingView)
        
        let velocity = recognizer.velocity(in: parent)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        
        if magnitude > throwingThreshold && recognizer.state == .ended {
            
            animator.removeAllBehaviors()
            
            let pushBehavior = UIPushBehavior(items: [snappingView], mode: .instantaneous)
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
            snapBehaviour = UISnapBehavior(item: snappingView, snapTo: normalizedCenter(snapPoint))
            
            animator.removeBehavior(pushBehavior)
            animator.addBehavior(snapBehaviour)
        } else {
            
            switch recognizer.state {
                
            case .began:
                xOFFset = touchLocation.x - snappingView.bounds.midX
                yOFFset = touchLocation.y - snappingView.bounds.midY
            case .changed:
                animator.removeAllBehaviors()
                var newCenter = CGPoint(x: location.x - xOFFset, y: location.y - yOFFset)
                let midX = snappingView.bounds.midX
                let midY = snappingView.bounds.midY
                
                let leftSide = newCenter.x - midX
                let rightSide = newCenter.x + midX
                let top = newCenter.y - midY
                let bottom = newCenter.y + midY
                
                if leftSide < 0 { newCenter.x = 0 + midX}
                if rightSide > parent.bounds.width { newCenter.x = parent.bounds.width - midX }
                if top < 0 { newCenter.y = 0 + midY }
                if bottom > parent.bounds.height { newCenter.y = parent.bounds.height - midY }
                
                snappingView.center = newCenter
            case .ended:
                animator.removeAllBehaviors()
                snapBehaviour = UISnapBehavior(item: snappingView, snapTo: snappingView.center)
                animator.addBehavior(snapBehaviour)
            default:
                break
            }
        }
    }
    
    /// returns center location to fit view withing screen bounds
    func normalizedCenter(_ center: CGPoint) -> CGPoint {
        let midX = snappingView.bounds.midX
        let midY = snappingView.bounds.midY
        
        var newCenter = center
        
        let leftSide = newCenter.x - midX
        let rightSide = newCenter.x + midX
        let top = newCenter.y - midY
        let bottom = newCenter.y + midY
        
        if leftSide < 0 { newCenter.x = 0 + midX}
        if rightSide > parent.bounds.width { newCenter.x = parent.bounds.width - midX }
        if top < 0 { newCenter.y = 0 + midY }
        if bottom > parent.bounds.height { newCenter.y = parent.bounds.height - midY }
        
        return newCenter
    }
    
    enum ScreenSquare {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    func screenSquare(at location: CGPoint) -> ScreenSquare {
        
        let squareSize = CGSize(width: parent.bounds.width/2, height: parent.bounds.height/2)
        let topLeftSquareOrigin = CGPoint(x: 0, y: 0)
        let topRightSquareOrigin = CGPoint(x: squareSize.width, y: 0)
        let bottomLeftSquareOrigin = CGPoint(x: 0, y: squareSize.height)
        
        let topLeftSquare = CGRect(origin: topLeftSquareOrigin, size: squareSize)
        let topRightSquare = CGRect(origin: topRightSquareOrigin, size: squareSize)
        let bottomLeftSquare = CGRect(origin: bottomLeftSquareOrigin, size: squareSize)
        
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
            return CGPoint(x: parent.bounds.width, y: 0)
        case .bottomLeft:
            return CGPoint(x: 0, y: parent.bounds.height)
        case .bottomRight:
            return CGPoint(x: parent.bounds.width, y: parent.bounds.height)
        }
    }
    
    func screenEdgeDirected(by angle: CGFloat, from location: CGPoint) -> CGPoint {
        
        let currentSquare = screenSquare(at: location)
        
        switch (currentSquare, angle) {
        /// topLeft
        case (.topLeft, 180), (.topLeft, (-179)...(-91)),
             (.topRight, 180), (.topRight, (-179)...(-91)),
             (.bottomLeft, (-135)...(-90)),
             (.bottomRight, (-160)...(-120)):
            return edge(for: .topLeft)
        /// topRight
        case (.topLeft, 0),
             (.topRight, (-90)...0),
             (.bottomLeft, (-89)...(-30)),
             (.bottomRight, (-91)...0):
            return edge(for: .topRight)
        /// bottomLeft
        case (.topLeft, 90),
             (.topRight, 91...160),
             (.bottomLeft, 90...180),
             (.bottomRight, 0):
            return edge(for: .bottomLeft)
        /// bottomRight
        case (.topLeft, 20...89),
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
