//
//  ConcurrentAudioFetch.swift
//  HLS Audio Player
//
//  Created by nk on 11/20/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import UIKit

class ConcurrentAudioFetch {
    
    typealias FetchCompletion = (URL?) -> Void
    typealias FetchProgressUpdate = (CGFloat) -> Void
    
    lazy var masterPlaylistURL: URL! = URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")
    lazy var playlist: M3U8Playlist! = M3U8Playlist(url: masterPlaylistURL)
    
    let responseQueue = DispatchQueue(label: "com.URLResponseSerialQueue", qos: .userInitiated)
    let requestQueue = DispatchQueue(label: "com.URLRequestConcurrentQueue", qos: .userInitiated, attributes: .concurrent)
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 2
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        return session
    }()
    
    var completion: FetchCompletion?
    var progressUpdate: FetchProgressUpdate?
    
    var segmentURI: URL!
    
    var bytePairs: [[(Int, Int)]]!
    var downloadedPairs: [[(Int, Int)]]!
    var currentPair = [(Int, Int)]()
    
    func initAudioSegmentsData() -> Bool {
        
        guard let audioSegments = playlist.bestQualityAudio?.segmentList,
            let segmentURI = audioSegments.first?.uri else {
                return false
        }
        self.segmentURI = segmentURI
        
        let byteRanges = audioSegments.flatMap ({ $0.byteRange }).map ({($0.1, $0.1 + $0.0 - 1)})
        
        /// create pairs for concurrent requests
        let byteRangePairs = byteRanges.reduce( [[(Int, Int)]]() ) { result, current in
            if let last = result.last,
                last.count < 2 {
                var newResult = result
                newResult.removeLast(1)
                let newPair: [(Int, Int)] = last + [current]
                return newResult + [newPair]
            } else {
                return result + [[current]]
            }
        }
        
        self.bytePairs = Array(byteRangePairs.reversed())
        
        return true
    }
    
    func fetchAudio(completion handler: @escaping FetchCompletion,
                             progressUpdate: @escaping FetchProgressUpdate) {
        
        self.completion = handler
        self.progressUpdate = progressUpdate
        
        guard initAudioSegmentsData() else {
            handler(nil)
            return
        }
        self.downloadedPairs = []
        self.nextPair()
    }
    
    func nextPair() {
    
        /// reset current pair
        self.currentPair = []
        if let pairToDownload = bytePairs.popLast() {
            
            for (index, byteRange) in pairToDownload.enumerated() {
                self.requestQueue.async {
                    var request = URLRequest(url: self.segmentURI)
                    request.addValue("bytes=\(byteRange.0)-\(byteRange.1)", forHTTPHeaderField: "Range")
                    
                    self.session.dataTask(with: request) { data,response,error in
                        self.responseQueue.async {
                            // add to current pair
                            self.currentPair = self.currentPair + [byteRange]
                            if self.currentPair.count == 2 {
                                // concatenate and go to next pair
                                self.nextPair()
                            }
                            let response = response as! HTTPURLResponse
                            debugPrint("Full request with response: \(response.statusCode) \(response.allHeaderFields["Content-Range"] ?? "")")
                        }
                        }.resume()
                }
            }
        } else {
            self.finalize()
        }
    }
    
    func finalize() {
        
    }
}
