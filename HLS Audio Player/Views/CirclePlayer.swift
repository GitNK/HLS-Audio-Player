//
//  CirclePlayer.swift
//  HLS Audio Player
//
//  Created by nk on 11/21/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit

@IBDesignable
class CirclePlayer: UIView {
    
    var state: State = .uninitialized {
        didSet {
            updateState()
        }
    }
    
    var backgroundRingLayer: CAShapeLayer!
    var downloadProgressRingLayer: CAShapeLayer!
    
    let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .black
        return indicator
    }()
    
    @IBInspectable
    var progress: CGFloat = 0.6 {
        didSet {
            updateProgress()
        }
    }
    @IBInspectable
    var backgroundLineWidth: CGFloat = 10.0 {
        didSet {
            updateLineWidth()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyInit()
    }
    
    private func applyInit() {
        
        addSubview(button)
        addSubview(activityIndicator)
        
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: button, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if backgroundRingLayer == nil {
            backgroundRingLayer = CAShapeLayer()
            layer.addSublayer(backgroundRingLayer)
            
            let rect = bounds.insetBy(dx: backgroundLineWidth / 2.0 , dy: backgroundLineWidth / 2.0)
            let path = UIBezierPath(ovalIn: rect)
            
            backgroundRingLayer.path = path.cgPath
            backgroundRingLayer.fillColor = nil
            backgroundRingLayer.lineWidth = backgroundLineWidth
            backgroundRingLayer.strokeColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1).cgColor
        }
        backgroundRingLayer.frame = layer.bounds
        
        if downloadProgressRingLayer == nil {
            downloadProgressRingLayer = CAShapeLayer()
            
            let innerRect = bounds.insetBy(dx: backgroundLineWidth / 2.0, dy: backgroundLineWidth / 2.0)
            
            let innerPath = UIBezierPath(ovalIn: innerRect)
            downloadProgressRingLayer.path = innerPath.cgPath
            downloadProgressRingLayer.fillColor = nil
            downloadProgressRingLayer.lineWidth = backgroundLineWidth
            downloadProgressRingLayer.strokeColor = #colorLiteral(red: 0.2527815998, green: 0.480304122, blue: 0.6649092436, alpha: 1).cgColor
            downloadProgressRingLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            downloadProgressRingLayer.transform = CATransform3DRotate(downloadProgressRingLayer.transform, -CGFloat.pi/2, 0, 0, 1)
            layer.addSublayer(downloadProgressRingLayer)
        }
        downloadProgressRingLayer.frame = layer.bounds
        updateProgress()
    }
    
    func updateProgress() {
        if let _ = downloadProgressRingLayer {
            downloadProgressRingLayer.strokeEnd = progress
        }
    }
    
    func updateLineWidth() {
        downloadProgressRingLayer?.lineWidth = backgroundLineWidth
        backgroundRingLayer?.lineWidth = backgroundLineWidth
    }
    
    func updateState() {
        switch state {
        case .uninitialized, .paused:
            activityIndicator.isHidden = true
            button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            button.isHidden = false
        case .fetching, .completed:
            button.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        case .playing:
            activityIndicator.isHidden = true
            button.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            button.isHidden = false
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 125, height: 125)
    }
}
