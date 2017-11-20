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
    
    var player: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actionPressed(_ sender: Any) {
        fetchAudio()
    }
    
    
    func fetchAudio() {
        
        let service = ConcurrentAudioFetch()
        //service.convert()
        service.fetchAudio(completion: { (audioURL) in
            if let audioURL = audioURL {
                self.player = AVPlayer(url: audioURL)
                self.player.play()
            }
        }) { (progress) in
            print("Donwloaded: \(progress)")
        }
    }
}
