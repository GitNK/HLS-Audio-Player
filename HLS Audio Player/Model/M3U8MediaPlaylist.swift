//
//  M3U8MediaPlaylist.swift
//  HLS Audio Player
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

struct M3U8MediaPlaylist {
    
    var baseURL: URL
    var originalURL: URL?
    var content: String
    
    var segmentList: [M3U8SegmentInfo]
    
    init?(url: URL) {
        let baseURL: URL = url.baseURL ?? url.deletingLastPathComponent()
        
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        self.init(content: content, baseURL: baseURL)
        originalURL = url
    }
    init?(content: String, baseURL: URL) {
        guard content.isMediaPlaylist else {
            return nil
        }
        self.content = content
        self.baseURL = baseURL
        segmentList = []
        self.parsePlaylistData()
    }
    
    private mutating func parsePlaylistData() {
        
        let lines = content.components(separatedBy: .newlines).filter {!$0.isEmpty}
        
        for (index, line) in lines.enumerated() {
        
            var attributes = [String: String]()
            attributes[Constants.M3U8Playlist.m3u8URL] = originalURL?.absoluteString
            attributes[Constants.M3U8Playlist.baseURL] = baseURL.absoluteString
            
            // #EXT-X-BYTERANGE:363780@0
            if let range = line.range(of: Constants.M3U8Playlist.byteRange) {
                let byteRange = String(line[range.upperBound..<line.endIndex])
                attributes[Constants.M3U8Playlist.byteRange] = byteRange
                attributes[Constants.M3U8Playlist.uri] = lines.count > index+1 ? lines[index+1] : nil
                
                let segment = M3U8SegmentInfo(dictionary: attributes)
                self.segmentList.append(segment)
            }
            
            
        
        }
    }
}
