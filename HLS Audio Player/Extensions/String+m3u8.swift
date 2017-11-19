//
//  String+m3u8.swift
//  HLS Audio Player
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import Foundation

extension String {
    
    /**
     The Extended M3U file format defines two tags: EXTM3U and EXTINF.  An
     Extended M3U file is distinguished from a basic M3U file by its first
     line, which MUST be #EXTM3U.
     
     reference url:http://tools.ietf.org/html/draft-pantos-http-live-streaming-00
     */
    var isExtendedM3UFile: Bool {
        return self.hasPrefix(Constants.M3U8Playlist.identifier)
    }
    
    var isMasterPlaylist: Bool {
        guard self.isExtendedM3UFile else {
            return false
        }
        let range1 = self.range(of: Constants.M3U8Playlist.streamInfo)
        let range2 = self.range(of: Constants.M3U8Playlist.iFrameStreamInfo)
        
        if range1 != nil || range2 != nil {
            return true
        } else {
            return false
        }
    }
    
    var isMediaPlaylist: Bool {
        guard self.isExtendedM3UFile else {
            return false
        }
        if let _ = self.range(of: Constants.M3U8Playlist.mediaInfo) {
            return true
        } else {
            return false
        }
    }
    
    var attributes: [String: String] {
        var attributes = [String : String]()
        let keyVals = self.components(separatedBy: ",").reduce([String]()) {
            result, cur in
            if let last = result.last,
                last.contains("="),
                !cur.contains("=") {
                var removingLast = result
                removingLast.removeLast(1)
                removingLast.append(last + "," + cur)
                return removingLast
            } else {
                return result + [cur]
            }
        }
        for keyVal in keyVals {
            let keyValArray = keyVal.components(separatedBy: "=")
            let key = keyValArray.first ?? ""
            let val = (keyValArray.last ?? "").replacingOccurrences(of: "\"", with: "")
            attributes[key] = val
        }
        return attributes
    }
}
