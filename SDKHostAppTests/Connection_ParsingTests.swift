//
//  Connection_ParsingTests.swift
//  IFTTT SDKTests
//
//  Copyright © 2019 IFTTT. All rights reserved.
//

import XCTest
@testable import IFTTTConnectSDK

class Connection_ParsingTests: XCTestCase {
    
    var connection: Connection!
    
    override func setUp() {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: Connection_ParsingTests.self)
        #endif
        if let path = bundle.url(forResource: "fetch_connection_response",
                                 withExtension: "json"),
            let json = try? Data(contentsOf: path) {
            let parser = Parser(content: json)
            connection = Connection(parser: parser)
        }
    }
    
    func test_fetchConnectionResponse() {
        XCTAssertNotNil(connection)
        if connection == nil {
            return
        }
        
        let id = connection.id
        XCTAssertEqual(id, "LMhuSZW9")
        
        let name = connection.name
        XCTAssertEqual(name, "Make time for all of your favorite shows on Netflix")
        
        let details = connection.description
        XCTAssertEqual(details, "Traveling and forgot to notify us? Now you can show Amex your location and not have to worry about it before your next vacation. Let's collapse longer descriptions.")

        let coverImage1080 = connection.coverImage(size: .w1080)?.url?.absoluteString
        XCTAssertEqual(coverImage1080, "https://ifttt.com/1080w", "Cover image not found")
        
        let bestCoverImage = connection.coverImage(for: 1600, scale: 1)?.url?.absoluteString
        XCTAssertEqual(bestCoverImage, "https://ifttt.com/1440w", "Best fit cover image not found")
        
        let firstFeature = connection.features.first
        XCTAssertEqual(firstFeature?.title, "Deliver to a location")
        XCTAssertEqual(firstFeature?.details, "Set a location and the grocery will be delivered there")
        XCTAssertEqual(firstFeature?.iconURL?.absoluteString, "https://ifttt.com/value-prop-icons/gps.png", "Feature not found")
        
        let firstTrigger = connection.activeUserTriggers.first
        switch firstTrigger {
        case .location(let region):
            XCTAssertEqual(region.radius, 123.4567890)
            XCTAssertEqual(region.center.latitude, 12.45678920)
            XCTAssertEqual(region.center.longitude, -98.5432112)
            XCTAssertEqual(region.identifier, "ifttt_somecoolidentifier")
        default:
            XCTFail("Expecting a location trigger")
        }
        
        let storage = Connection.ConnectionStorage(connection: connection)
        XCTAssertEqual(storage.hasLocationTriggers, true)
        
        if let firstRegion = storage.locationRegions.first {
            XCTAssertEqual(firstRegion.radius, 123.4567890)
            XCTAssertEqual(firstRegion.center.latitude, 12.45678920)
            XCTAssertEqual(firstRegion.center.longitude, -98.5432112)
            XCTAssertEqual(firstRegion.identifier, "ifttt_somecoolidentifier")
        } else {
            XCTFail("Expecting a region to be returned")
        }
    }
    
    func test_stripIFTTTPrefix() {
        let testNonIFTTTIdentifier = "1234"
        assert(testNonIFTTTIdentifier.stripIFTTTPrefix() == testNonIFTTTIdentifier)
        
        let testIFTTTIdentifier = "IFTTT_1234"
        assert(testIFTTTIdentifier.stripIFTTTPrefix() == "1234")
        
        let testMisspelledIFTTTIdentifier = "IFTT_1234"
        assert(testMisspelledIFTTTIdentifier.stripIFTTTPrefix() == testMisspelledIFTTTIdentifier)
    }
    
    func test_addIFTTTPrefix() {
        let testIdentifier = "1234"
        assert(testIdentifier.addIFTTTPrefix() == "ifttt_1234")
    }
}
