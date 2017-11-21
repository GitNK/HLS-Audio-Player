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
    
    let snapConfigurator = SnappableViewConfigurator()
    
    @IBOutlet var circlePlayer: CirclePlayer!
    
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        circlePlayer.button.addTarget(self, action: #selector(actionPerformed(_:)), for: .touchUpInside)
        circlePlayer.progress = 0.0
        circlePlayer.state = .uninitialized
        circlePlayer.center = view.center
        
        snapConfigurator.addSnapping(for: circlePlayer, parent: view)
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
    
    func fetchAudio() {
        DispatchQueue.global().async {
            let service = ConcurrentAudioFetch()
            //service.convert()
            service.fetchAudio(completion: { (audioURL) in
                DispatchQueue.main.async {
                    if let audioURL = audioURL {
                        self.player = AVPlayer(url: audioURL)
                        self.player.play()
                        NotificationCenter.default.addObserver(self,
                                                               selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                               object: self.player.currentItem)
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
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        state = .completed
        FileService.removeMP4File()
        state = .uninitialized
        circlePlayer.progress = 0.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
        FileService.removeMP4File()
    }
}
