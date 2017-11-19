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
    
    init(dictionary: [String: String]) {
        
        if let resolutionString = dictionary[Constants.M3U8Playlist.resolution],
            case let components = resolutionString.components(separatedBy: "x"), components.count == 2 {
            let width = CGFloat((components[0] as NSString).floatValue)
            let height = CGFloat((components[1] as NSString).floatValue)
            resolution = CGSize(width: width, height: height)
        } else {
            resolution = .zero
        }
    }
}
