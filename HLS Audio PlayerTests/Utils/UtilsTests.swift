//
//  UtilsTests.swift
//  HLS Audio PlayerTests
//
//  Created by nk on 11/19/17.
//  Copyright © 2017 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import HLS_Audio_Player

class UtilsTests: XCTestCase {
    
    let streamLine = "AVERAGE-BANDWIDTH=2247704,BANDWIDTH=2256841,CODECS=\"avc1.640020,ec-3\",RESOLUTION=960x540,FRAME-RATE=60.000,CLOSED-CAPTIONS=\"cc1\",AUDIO=\"aud3\",SUBTITLES=\"sub1\""
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_ParseLine_ReturnAttributes() {
        let attributes: [String: String] =
            [
                "AVERAGE-BANDWIDTH" : "2247704",
                "BANDWIDTH" : "2256841",
                "CODECS" : "avc1.640020,ec-3",
                "RESOLUTION" : "960x540",
                "FRAME-RATE" : "60.000",
                "CLOSED-CAPTIONS" : "cc1",
                "AUDIO" : "aud3",
                "SUBTITLES" : "sub1"
            ]
        XCTAssertEqual(streamLine.attributes,
                       attributes,
                       "Should correctly parse attributes")
    }
}
