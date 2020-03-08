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
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    // This test check exacly the implementation of URLSession class, but we don't want that.
    // We don't own "URLSession" so it's better to check the behaviour not the implementation.
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        // Now we need to tell the session to return our task for a given url.
        // We create a stub method.
        session.stub(url: url, with: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Helpers
    
    // It's dangerous to subclass this classes "URLSession" & "FakeURLSessionDataTask" because we don't own them,
    // they are part of "Foundation".
    // We don't have access to the implementation.
    // We can start to create assumption, in our mock classes, that can be wrong.
    
    private class URLSessionSpy: URLSession {

        private var stubs = [URL: URLSessionDataTask]()
        
        override init() {}
        
        func stub(url: URL, with task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override init() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override init() {}
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
