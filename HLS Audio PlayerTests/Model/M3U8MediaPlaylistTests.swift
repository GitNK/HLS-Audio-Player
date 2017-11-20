//
//  M3U8MediaPlaylistTests.swift
//  HLS Audio PlayerTests
//
//  Created by nk on 11/20/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import HLS_Audio_Player

class M3U8MediaPlaylistTests: XCTestCase {
    
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
        let playlist = M3U8MediaPlaylist(url: invalidURL)
        XCTAssertNil(playlist, "Should return nil on invalid URL")
    }
    
}
