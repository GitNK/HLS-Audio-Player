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
    
    let masterStreamURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Init_WhenGivenValidURL_ReturnsInstance() {
        let playlist = M3U8Playlist(url: masterStreamURL)
        XCTAssertNotNil(playlist, "Should init with valid URL")
    }
    
    func test_Init_WhenGivenInvalidURL_ReturnsNil() {
        let invalidURL = URL(string: "http://example.com/")!
        let playlist = M3U8Playlist(url: invalidURL)
        XCTAssertNil(playlist, "Should return nil on invalid URL")
    }
    
    func test_Init_WhenGivenURL_SetsOriginalURL() {
        let playlist = M3U8Playlist(url: masterStreamURL)!
        XCTAssertEqual(playlist.originalURL, masterStreamURL, "Should set original URL")
    }
    
    func test_Init_WhenGivenURL_SetsBaseURL() {
        let playlist = M3U8Playlist(url: masterStreamURL)!
        XCTAssertEqual(playlist.baseURL, masterStreamURL.deletingLastPathComponent(), "Should set base url")
    }
    
    func test_Init_WhenGivenValidContent_ReturnsInstance() {
        let m3u8Content = "\(Constants.M3U8Playlist.identifier)"
        XCTAssertNotNil(M3U8Playlist(content: m3u8Content, baseURL: masterStreamURL.deletingLastPathComponent()), "Should init with valid content")
    }
    
    func test_Init_WhenGivenInvalidContent_ReturnsNil() {
        let invalidContent = "This is not a valid content for M3U8 Playlist"
        XCTAssertNil(M3U8Playlist(content: invalidContent, baseURL: masterStreamURL.deletingLastPathComponent()), "Should return nil on invalid content")
    }
    
}
