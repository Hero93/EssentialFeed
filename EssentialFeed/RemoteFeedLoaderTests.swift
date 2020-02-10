//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luca LG. Gramaglia on 10/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "http://a-url.com")
    }
}

class HTTPClient {
    
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        // sut -> System under test
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        // Arrange
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        // Act
        sut.load()
        
        // Assert
        XCTAssertNotNil(client.requestedURL)
    }
}
