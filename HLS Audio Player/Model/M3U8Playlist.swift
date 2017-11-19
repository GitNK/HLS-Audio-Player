//
//  M3U8Playlist.swift
//  HLS Audio Player
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

struct M3U8Playlist {
    
    var originalURL: URL?
    let baseURL: URL
    
    var masterPlaylist: M3U8MasterPlaylist?
    
    var mainMediaPlaylist: M3U8MediaPlaylist?
    var audioPlaylist: M3U8MediaPlaylist?
    
    /// init with valid m3u8 `url`
    /// returns `nil` if input `url` is invalid
    init?(url: URL) {
        let baseURL: URL = url.baseURL ?? url.deletingLastPathComponent()
        
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        self.init(content: content, baseURL: baseURL)
        originalURL = url
    }
    /// init with playlist `content` and `baseURL`
    /// returns `nil` if `content` is of invalid format
    init?(content: String, baseURL: URL) {
        guard content.isExtendedM3UFile else {
            return nil
        }
        self.baseURL = baseURL
        
        if content.isMasterPlaylist {
            
            self.masterPlaylist = M3U8MasterPlaylist(content: content, baseURL: baseURL)
            self.audioPlaylist = M3U8MediaPlaylist()
            self.mainMediaPlaylist = M3U8MediaPlaylist()
            
        } else if content.isMediaPlaylist {
            
            self.mainMediaPlaylist = M3U8MediaPlaylist()
        }
        
        
        
    }
}
