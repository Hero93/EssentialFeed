//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Luca Gramaglia on 08/03/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import XCTest
import Foundation

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
                
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    // MARK: - Helpers
    
    // It's dangerous to subclass this classes "URLSession" & "FakeURLSessionDataTask" because we don't own them,
    // they are part of "Foundation".
    // We don't have access to the implementation.
    // We can start to create assumption, in our mock classes, that can be wrong.
    
    private class URLSessionSpy: URLSession {
        
        // We want to check that "URLSession" class receives the correct url
        // We don't have access to the received urls so we need to "spy" the class
        var receivedURLs = [URL]()
        
        override init() {}
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override init() {}
    }
}
