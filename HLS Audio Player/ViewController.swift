//
//  ViewController.swift
//  HLS Audio Player
//
//  Created by nk on 11/18/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    enum State {
        case uninitialized
        case fetching
        case playing
        case paused
        case completed
    }
    
    var state: State = .uninitialized {
        didSet {
            updateState()
        }
    }
    
    @IBOutlet var button: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var circlePlayer: CirclePlayer!
    
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateState()
        circlePlayer.progress = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actionPressed(_ sender: Any) {
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
}
