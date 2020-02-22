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
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliverErrorOnNon200HTTPResponse() {
        // Arrange
        let (sut, client) = makeSUT()

        // Act
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWithResult: .failure(.inavalidData), when: {
                let emptyJson = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyJson, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.inavalidData), when: {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        })
    }
    
    func test_load_deliversNoIemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJson = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "A description",
                             location: "A Location",
                             imageURL: URL(string: "http://a-url.com")!)
        
        let items = [item1.model, item2.model]
                
        expect(sut, toCompleteWithResult: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut =  RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithResult result: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
                
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load() { capturedResults.append($0) }
                
        action()
        
        // When the test fails, it fails in the exact line, not here.
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    // Factory method
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            // this functions adds only the non-nil values inside the dictionary
            if let value = e.value { acc[e.key] = value }
        }

        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    // The spy job is to capture the messages (invokations) in a clear way.
    // How many times the message was invoked, with what parameters and in which order.
    
    private class HTTPClientSpy: HTTPClient {
        
        // message passing = invoking behavior
        // in this case calling the method "get" is the "message"
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
