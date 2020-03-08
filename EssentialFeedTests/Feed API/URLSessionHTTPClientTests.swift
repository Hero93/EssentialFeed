//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Luca Gramaglia on 08/03/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import XCTest
import Foundation
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
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
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "any domain", code: 1)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error: \(error) got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    // It's dangerous to subclass this classes "URLSession" & "FakeURLSessionDataTask" because we don't own them,
    // they are part of "Foundation".
    // We don't have access to the implementation.
    // We can start to create assumption, in our mock classes, that can be wrong.
    
    private class URLSessionSpy: URLSession {

        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        override init() {}
        
        func stub(url: URL, with task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
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
