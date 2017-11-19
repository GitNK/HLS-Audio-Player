//
//  M3U8MediaInfo.swift
//  HLS Audio Player
//
//  Created by nk on 11/20/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

struct M3U8MediaInfo {
    
    var baseURL: URL?
    var url: URL?
    var type: String?
    var uri: URL?
    var groupID: String?
    
    init(dictionary: [String: String]) {
        if let baseURLstring = dictionary[Constants.M3U8Playlist.baseURL] {
            self.baseURL = URL(string: baseURLstring)
        }
        if let urlString = dictionary[Constants.M3U8Playlist.m3u8URL] {
            self.url = URL(string: urlString)
        }
        self.type = dictionary[Constants.M3U8Playlist.mediaType]
        if let uriString = dictionary[Constants.M3U8Playlist.uri] {
            self.uri = URL(string: uriString)
        }
        self.groupID = dictionary[Constants.M3U8Playlist.groupID]
    }
}
