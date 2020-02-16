//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luca LG. Gramaglia on 10/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    // The method naming convention is:
    // test
    // _init -> the method we are testing
    // _doesNotRequestDataFromURL -> the behaviour we expect
    
    func test_init_doesNotRequestDataFromURL() {
        // sut -> System under test
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        // Arrange
        let url = URL(string: "http://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // Act
        sut.load() { _ in }
        
        // When testing objects collaborating, asserting the values passed is not enough.
        // We also need to ask, how many times was the method invoked ?
        
        // Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // Arrange
        let url = URL(string: "http://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // Act
        
        // By mistake the client get called twice (it can happend after a git merge)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        // When testing objects collaborating, asserting the values passed is not enough.
        // We also need to ask, how many times was the method invokd ?
        
        // Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliverErrorOnClientError() {
        // Arrange
        let (sut, client) = makeSUT()

        // Act
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        // Assert
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliverErrorOnNon200HTTPResponse() {
        // Arrange
        let (sut, client) = makeSUT()

        // Act
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { capturedErrors.append($0) }
        
        client.complete(withStatusCode: 400)
        
        // Assert
        XCTAssertEqual(capturedErrors, [.inavalidData])
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    // The spy job is to capture the messages (invokations) in a clear way.
    // How many times the message was invoked, with what parameters and in which order.
    
    private class HTTPClientSpy: HTTPClient {
        // message passing = invoking behavior
        // in this case calling the method "get" is the "message"
        var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil
            )
            messages[index].completion(nil, response)
        }
    }
}
