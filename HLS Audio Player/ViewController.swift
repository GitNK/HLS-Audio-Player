//
//  ViewController.swift
//  HLS Audio Player
//
//  Created by nk on 11/18/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
        service.fetchAudio(completion: { (audioURL) in
            
        }) { (progress) in
            print("Donwloaded: \(progress)")
        }
    }
}
