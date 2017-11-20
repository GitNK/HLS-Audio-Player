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
    
    let tempFileURL: URL = {
       let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return url.appendingPathComponent("audio.ts")
    }()
    
    let newTempFileURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return url.appendingPathComponent("newAudio.ts")
    }()
    
    let mp4FileURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return url.appendingPathComponent("audio.mp4")
    }()
    
    var completion: FetchCompletion?
    var progressUpdate: FetchProgressUpdate?
    
    var segmentURI: URL!
    
    var bytePairs: [[(Int, Int)]]!
    /// currently downloaded data
    var downloadedData = [Int: Data]()
    
    var totalNumberOfSegments: Int! {
        didSet {
            print("total num: \(totalNumberOfSegments)")
        }
    }
    var segmentsDownloaded: Int! {
        didSet {
            /// update progress
            progressUpdate?(CGFloat(segmentsDownloaded)/CGFloat(totalNumberOfSegments))
            print("downloaded: \(segmentsDownloaded)")
        }
    }
    
    func initAudioSegmentsData() -> Bool {
        
        guard let audioSegments = playlist.bestQualityAudio?.segmentList,
            let segmentURI = audioSegments.first?.uri else {
                return false
        }
        self.segmentURI = segmentURI
        
        let byteRanges = audioSegments.flatMap ({ $0.byteRange }).map ({($0.1, $0.1 + $0.0 - 1)})
        
        self.totalNumberOfSegments = byteRanges.count
        
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
        self.segmentsDownloaded = 0
        self.nextPair()
    }
    
    func nextPair() {
    
        /// reset downloaded data
        self.downloadedData = [:]
        if let pairToDownload = bytePairs.popLast() {
            
            for (index, byteRange) in pairToDownload.enumerated() {
                self.requestQueue.async {
                    var request = URLRequest(url: self.segmentURI)
                    request.addValue("bytes=\(byteRange.0)-\(byteRange.1)", forHTTPHeaderField: "Range")
                    
                    self.session.dataTask(with: request) { data,response,error in
                        self.responseQueue.async {
                            // add to dowloaded data
                            self.downloadedData[index] = data
                            self.incrementDownloadedSegments()
                            let response = response as! HTTPURLResponse
                            debugPrint("Full request with response: \(response.statusCode) \(response.allHeaderFields["Content-Range"] ?? "")")
                            if self.downloadedData.count == 2 || (self.segmentsDownloaded == self.totalNumberOfSegments) {
                                // concatenate and save downloaded data
                                self.saveDownloadedData()
                                // go to next pair
                                self.nextPair()
                            }
                        }
                        }.resume()
                }
            }
        } else {
            self.finalize()
        }
    }
    
    func finalize() {
        do {
            let data = try Data(contentsOf: tempFileURL)
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
            bcf.countStyle = .file
            let string = bcf.string(fromByteCount: Int64(data.count))
            print(string)
            
            let mpegConverter = FFmpegWrapper()
            let options: [String: String] = [kFFmpegInputFormatKey: "ts", kFFmpegOutputFormatKey: "mp4"]
            mpegConverter.convertInputPath(tempFileURL.relativePath, outputPath: mp4FileURL.relativePath, options: options, progressBlock: { (_, _, _) in
                
            }, completionBlock: { _,_ in
                
                /// remove temp file
                try? FileManager.default.removeItem(at: self.tempFileURL)
                self.completion?(self.mp4FileURL)
            })
            
        } catch {
            fatalError()
        }
    }
    
    func incrementDownloadedSegments() {
        segmentsDownloaded = segmentsDownloaded + 1
    }
    
    func saveDownloadedData() {
        
        /// concatanate downloaded data
        var data = Data()
        let sortedKeyVals = downloadedData.sorted { $0.0 < $1.0 }
        for keyVal in sortedKeyVals {
            data.append(keyVal.value)
        }
        /// write to file
        do {
            try data.append(fileURL: tempFileURL)
        }
        catch {
            print("Could not write to file")
            completion?(nil)
        }
        
    }
    
    func convert() {
        let mpegConverter = FFmpegWrapper()
        let options: [String: String] = [kFFmpegInputFormatKey: "ts", kFFmpegOutputFormatKey: "mp4"]
        mpegConverter.convertInputPath(tempFileURL.relativePath, outputPath: mp4FileURL.relativePath, options: options, progressBlock: { (_, _, _) in
            
        }, completionBlock: {_,_ in
            
        })
        
    }
}
