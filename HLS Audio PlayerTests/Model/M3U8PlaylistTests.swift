//
//  M3U8PlaylistTests.swift
//  HLS Audio PlayerTests
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import HLS_Audio_Player

class M3U8PlaylistTests: XCTestCase {
    
    let masterURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    let mediaURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/a1/prog_index.m3u8")!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Init_WhenGivenInvalidURL_ReturnsNil() {
        let invalidURL = URL(string: "http://example.com/")!
        let playlist = M3U8Playlist(url: invalidURL)
        XCTAssertNil(playlist, "Should return nil on invalid URL")
    }
    
    func test_Init_WhenGivenURL_SetsOriginalURL() {
        let playlist = M3U8Playlist(url: URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")!)!
        XCTAssertEqual(playlist.originalURL, masterURL, "Should set original URL")
    }
    
    func test_Init_WhenGivenURL_SetsBaseURL() {
        let playlist = M3U8Playlist(url: masterURL)!
        XCTAssertEqual(playlist.baseURL, masterURL.deletingLastPathComponent(), "Should set base url")
    }
    
    func test_Init_WhenGivenValidContent_ReturnsInstance() {
        let m3u8Content = Constants.M3U8Playlist.identifier
        XCTAssertNotNil(M3U8Playlist(content: m3u8Content, baseURL: masterURL.deletingLastPathComponent(), originalURL: masterURL), "Should init with valid content")
    }
    
    func test_Init_WhenGivenInvalidContent_ReturnsNil() {
        let invalidContent = "This is not a valid content for M3U8 Playlist"
        XCTAssertNil(M3U8Playlist(content: invalidContent, baseURL: masterURL.deletingLastPathComponent(), originalURL: masterURL), "Should return nil on invalid content")
    }
    
    func test_Init_WhenGivenMasterPlaylist_SetsMasterPlaylist() {
        let playlist = M3U8Playlist(url: masterURL)!
        XCTAssertNotNil(playlist.mainMediaPlaylist, "Should set mainMedia playlist")
        XCTAssertNotNil(playlist.masterPlaylist, "Should set mainMedia playlist")
        XCTAssertNil(playlist.audioPlaylist, "Should not set audio playlist")
    }
    
    func test_Init_WhenGivenMediaPlaylist_SetsMediaPlaylist() {
        let playlist = M3U8Playlist(url: mediaURL)!
        XCTAssertNotNil(playlist.mainMediaPlaylist, "Should set mainMedia playlist")
        XCTAssertNil(playlist.masterPlaylist, "Should not set mainMedia playlist")
        XCTAssertNil(playlist.audioPlaylist, "Should not set audio playlist")
    }
}
