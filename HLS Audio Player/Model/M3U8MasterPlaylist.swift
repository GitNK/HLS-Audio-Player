//
//  M3U8MasterPlaylist.swift
//  HLS Audio Player
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

struct M3U8MasterPlaylist {
    
    var baseURL: URL
    var originalURL: URL?
    var content: String
    var version: String?
    
    var streamList: [M3U8StreamInfo]
    
    /// init with valid master m3u8 `url`
    /// returns `nil` if input `url` is invalid
    init?(url: URL) {
        let baseURL: URL = url.baseURL ?? url.deletingLastPathComponent()
        
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        self.init(content: content, baseURL: baseURL)
        originalURL = url
    }
    /// init with master playlist `content` and `baseURL`
    /// returns `nil` if `content` is of invalid format
    init?(content: String, baseURL: URL) {
        guard content.isMasterPlaylist else {
            return nil
        }
        self.content = content
        self.baseURL = baseURL
        self.streamList = []
        self.parsePlaylistData()
    }
    
    private mutating func parsePlaylistData() {
        
        let lines = content.components(separatedBy: .newlines).filter {!$0.isEmpty}
        for (index, line) in lines.enumerated() {
            
            // #EXT-X-VERSION:4
            if let range = line.range(of: Constants.M3U8Playlist.version) {
                let version = line[range.upperBound..<line.endIndex]
                self.version = String(version)
            }
                // #EXT-X-STREAM-INF:AUDIO="600k",BANDWIDTH=915685,PROGRAM-ID=1,CODECS="avc1.42c01e,mp4a.40.2",RESOLUTION=640x360,SUBTITLES="subs"
                // http://hls.ted.com/talks/769/video/600k.m3u8?sponsor=Ripple
            else if let range = line.range(of: Constants.M3U8Playlist.streamInfo) {
                let streamLine = String(line[range.upperBound..<line.endIndex])
                var attributes = streamLine.attributes
                
                // parse URI
                attributes[Constants.M3U8Playlist.uri] = lines.count > index+1 ? lines[index+1] : nil
                attributes[Constants.M3U8Playlist.m3u8URL] = self.originalURL?.absoluteString
                attributes[Constants.M3U8Playlist.baseURL] = self.baseURL.absoluteString
                
                let streamInfo = M3U8StreamInfo(dictionary: attributes)
                self.streamList.append(streamInfo)
            }
            
        }
    }
}
