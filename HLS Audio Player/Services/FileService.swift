//
//  FileService.swift
//  HLS Audio Player
//
//  Created by nk on 11/21/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

struct FileService {
    
   static let tempFileURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return url.appendingPathComponent("audio.ts")
    }()
    
   static let mp4FileURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return url.appendingPathComponent("audio.mp4")
    }()
    
    static func removeTempFile() {
        try? FileManager.default.removeItem(at: tempFileURL)
    }
    
    static func removeMP4File() {
        try? FileManager.default.removeItem(at: mp4FileURL)
    }
    
}
