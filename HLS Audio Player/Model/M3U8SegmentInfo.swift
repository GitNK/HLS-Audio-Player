//
//  M3U8SegmentInfo.swift
//  HLS Audio Player
//
//  Created by nk on 11/20/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

struct M3U8SegmentInfo {
    
    var originalURL: URL?
    var baseURL: URL?
    var uri: URL?
    
    var byteRange: (Int, Int)?
    
    init(dictionary: [String : String]) {
        
        if let originalURLstring = dictionary[Constants.M3U8Playlist.m3u8URL] {
            self.originalURL = URL(string: originalURLstring)
        }
        
        if let baseURLstring = dictionary[Constants.M3U8Playlist.baseURL] {
            self.baseURL = URL(string: baseURLstring)
        }
        
        if let uriString = dictionary[Constants.M3U8Playlist.uri] {
            self.uri = URL(string: uriString, relativeTo: baseURL)
        }
        
        if let byteRange = dictionary[Constants.M3U8Playlist.byteRange]?.components(separatedBy: "@"),
            let first = byteRange.first,
            let second = byteRange.last,
            let lenght = Int(first),
            let offset = Int(second) {
            self.byteRange = (lenght, offset)
        }
    }
}
