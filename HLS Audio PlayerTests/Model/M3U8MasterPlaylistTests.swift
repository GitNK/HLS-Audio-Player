//
//  M3U8MasterPlaylistTests.swift
//  HLS Audio PlayerTests
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import HLS_Audio_Player

class M3U8MasterPlaylistTests: XCTestCase {
    
    let masterURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
    let masterURL2 = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
    
    var masterPlaylist: M3U8MasterPlaylist!
        
    override func setUp() {
        super.setUp()
        masterPlaylist = M3U8MasterPlaylist(url: masterURL)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Init_WhenGivenInvalidURL_ReturnsNil() {
        let invalidURL = URL(string: "http://example.com/")!
        let playlist = M3U8MasterPlaylist(url: invalidURL)
        XCTAssertNil(playlist, "Should return nil on invalid URL")
    }
    
    func test_Init_WhenGivenURL_SetsOriginalURL() {
        
        XCTAssertEqual(masterPlaylist.originalURL, masterURL, "Should set original URL")
    }
    
    func test_Init_WhenGivenURL_SetsBaseURL() {
        
        XCTAssertEqual(masterPlaylist.baseURL, masterURL.deletingLastPathComponent(), "Should set base url")
    }
    
    func test_Init_WhenGivenValidContent_SetsSame() {
        let m3u8Content = Constants.M3U8Playlist.identifier + "\n" + Constants.M3U8Playlist.streamInfo
        let playlist = M3U8MasterPlaylist(content: m3u8Content, baseURL: masterURL.deletingLastPathComponent())!
        XCTAssertEqual(playlist.content, m3u8Content, "Content should equal to one used during init")
        
    }
    
    func test_Init_WhenGivenInvalidContent_ReturnsNil() {
        let invalidContent = "This is not a valid content for M3U8 Playlist"
        XCTAssertNil(M3U8MasterPlaylist(content: invalidContent, baseURL: masterURL.deletingLastPathComponent()), "Should return nil on invalid content")
    }
    
    func test_StreamListCount_Is24() {
        XCTAssertEqual(masterPlaylist.streamList.count, 24, "Number of streams should be 24")
    }
    
    func test_StreamListCount_Is6() {
        let playlist = M3U8MasterPlaylist(url: masterURL2)!
        XCTAssertEqual(playlist.streamList.count, 6, "Number of streams should be 6")
    }
    
    func test_StreamListFirstItemResolution_Is_960x540(){
        XCTAssertEqual(masterPlaylist.streamList.first?.resolution, CGSize(width: 960, height: 540), "Resolution of first stream should be 960x540")
    }
    
    func test_StreamListFirstItemBandwidth_Is_2227464() {
        XCTAssertEqual(masterPlaylist.streamList.first?.bandwidth, 2227464, "Bandwidth of first stream should be 2227464")
    }
    
    func test_StreamListFirstItemAudio_Is_aud1() {
        XCTAssertEqual(masterPlaylist.streamList.first?.audio, "aud1", "Audio of first stream should be aud1")
    }
    
    func test_StreamListFirstItemURI() {
        XCTAssertEqual(masterPlaylist.streamList.first?.uri, URL(string: "v5/prog_index.m3u8"), "URI of first stream should be v5/prog_index.m3u8")
    }
    
    func test_MediaListCount_Is5() {
        XCTAssertEqual(masterPlaylist.mediaList.count, 5, "Number of media should be 5")
    }
    
    func test_MediaListCount_Is10() {
        let playlist = M3U8MasterPlaylist(url: masterURL2)!
        XCTAssertEqual(playlist.mediaList.count, 10, "Number of media should be 10")
    }
    
    func test_MediaListFirstItemGroup_Is_aud1() {
        XCTAssertEqual(masterPlaylist.mediaList.first?.groupID, "aud1", "Group id of first media should be aud1")
    }
    func test_MediaListFirstItemURI() {
        XCTAssertEqual(masterPlaylist.mediaList.first?.uri, URL(string: "a1/prog_index.m3u8")!)
    }
}
