//
//  Constants.swift
//  HLS Audio Player
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

struct Constants {
    
    struct M3U8Playlist {
        
        static let identifier: String = "#EXTM3U"
        static let streamInfo: String = "#EXT-X-STREAM-INF:"
        static let iFrameStreamInfo: String = "#EXT-X-I-FRAME-STREAM-INF:"
        static let mediaInfo: String = "#EXTINF:"
        static let version: String = "#EXT-X-VERSION:"
        static let resolution: String = "RESOLUTION"
        static let m3u8URL: String = "URL"
        static let baseURL: String = "baseURL"
        static let media: String = "#EXT-X-MEDIA:"
        static let uri: String = "URI"
    }
}
