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
    
    var state: State = .uninitialized {
        didSet {
            circlePlayer.state = state
        }
    }
    
    @IBOutlet var circlePlayer: CirclePlayer!
    
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        circlePlayer.button.addTarget(self, action: #selector(actionPerformed(_:)), for: .touchUpInside)
        circlePlayer.progress = 0.0
        circlePlayer.state = .uninitialized
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
}
