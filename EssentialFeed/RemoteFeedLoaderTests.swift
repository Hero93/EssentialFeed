//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luca LG. Gramaglia on 10/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    
}

class APIClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = APIClient()
        // sut -> System under test
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
