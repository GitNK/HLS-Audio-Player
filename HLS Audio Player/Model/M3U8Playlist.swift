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
    var baseURL: URL
    
    var content: String
    
    var masterPlaylist: M3U8MasterPlaylist?
    
    var mainMediaPlaylist: M3U8MediaPlaylist?
    var audioPlaylist: M3U8MediaPlaylist?
    
    var bestQualityAudio: M3U8MediaPlaylist?
    
    /// init with valid m3u8 `url`
    /// returns `nil` if input `url` is invalid
    init?(url: URL) {
        let baseURL: URL = url.baseURL ?? url.deletingLastPathComponent()
        
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        self.init(content: content, baseURL: baseURL, originalURL: url)
    }
    /// init with playlist `content` and `baseURL`
    /// returns `nil` if `content` is of invalid format
    init?(content: String, baseURL: URL, originalURL: URL) {
        guard content.isExtendedM3UFile else {
            return nil
        }
        self.content = content
        self.baseURL = baseURL
        self.originalURL = originalURL
        
        parsePlaylistData()
    }
    
    private mutating func parsePlaylistData() {
        
        if content.isMasterPlaylist {
            
            self.masterPlaylist = M3U8MasterPlaylist(content: content,
                                                     baseURL: baseURL)
            
            if let currentStream = masterPlaylist?.streamList.first,
                let m3u8URL = currentStream.uri {
                
                self.mainMediaPlaylist = M3U8MediaPlaylist(url: m3u8URL)
            }
            
            // get audio playlist
            for stream in masterPlaylist!.streamList {
                if let codecs = stream.codecs,
                    codecs.count == 1,
                    codecs.first?.hasPrefix("mp4a") == true,
                    let audioURL = stream.uri {
                    self.audioPlaylist = M3U8MediaPlaylist(url: audioURL)
                    break
                }
            }
            
        } else if content.isMediaPlaylist,
            let url = originalURL {
            
            self.mainMediaPlaylist = M3U8MediaPlaylist(url: url)
        }
        self.bestQualityAudio = getBestQualityAudio()
    }
    
    func getBestQualityAudio() -> M3U8MediaPlaylist? {
        /// sort streams from master playlist by bandwidth
        let streams = masterPlaylist?.streamList.sorted(by: {$0.bandwidth < $1.bandwidth}) ?? []
        /// select stream with highest bandwidth
        guard let bestStream = streams.last,
            let audioName = bestStream.audio else {
            return nil
        }
        /// find audio for this stream which should be of best quality
        guard let audio = masterPlaylist?.mediaList.filter ({ $0.groupID == audioName }).first,
            let audioURI = audio.uri,
            let audioBaseURL = audio.baseURL,
            let audioURL = URL(string: audioURI.absoluteString, relativeTo: audioBaseURL)
        else {
            return nil
        }
        /// create and return media playlist
        let audioPlaylist = M3U8MediaPlaylist(url: audioURL)
        return audioPlaylist
    }
}
