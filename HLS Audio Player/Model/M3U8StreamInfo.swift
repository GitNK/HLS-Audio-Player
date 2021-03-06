//
//  M3U8StreamInfo.swift
//  HLS Audio Player
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit

struct M3U8StreamInfo {
    
    var resolution: CGSize
    var bandwidth: Int
    var audio: String?
    var uri: URL?
    var codecs: [String]?
    var baseURL: URL?
    
    init(dictionary: [String: String]) {
        
        if let baseURLString = dictionary[Constants.M3U8Playlist.baseURL],
            let baseURL = URL(string: baseURLString),
            let uriString = dictionary[Constants.M3U8Playlist.uri] {
            self.baseURL = baseURL
            self.uri = URL(string: uriString, relativeTo: baseURL)
        }
        
        if let resolutionString = dictionary[Constants.M3U8Playlist.resolution],
            case let components = resolutionString.components(separatedBy: "x"), components.count == 2 {
            let width = CGFloat((components[0] as NSString).floatValue)
            let height = CGFloat((components[1] as NSString).floatValue)
            resolution = CGSize(width: width, height: height)
        } else {
            resolution = .zero
        }
        
        if let bandwidthString = dictionary[Constants.M3U8Playlist.bandwidth],
            let bandwidth = Int(bandwidthString) {
            self.bandwidth = bandwidth
        } else {
            self.bandwidth = 0
        }
        
        self.audio = dictionary[Constants.M3U8Playlist.audio]
        self.codecs = dictionary[Constants.M3U8Playlist.codecs]?.components(separatedBy: ",")
    }
}
