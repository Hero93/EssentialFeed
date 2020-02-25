//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Luca LG. Gramaglia on 15/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import Foundation

// "RemoteFeedLoader" will not depend on concrete type like URLSession but by creating a clean separation between protocols,
// we make the RemoteFeedLoader more flexible, open for extensions and more testable.

// It's public because it can be implemented and created by external modules

public class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    // The "RemoteFeedLoader" doesn't need to locate or instantiate the HTTPClient instance.
    // We can make our code more modular, by injecting the HTTPClient as a dependency. (Open/Close principle)
    
    // Usually the HTTPClient is created as a Singleton -> by doing this I introduce high coupoling between the modules.
    
    // This error is in the domain of the implementation of the HTTPClient
    public enum Error: Swift.Error {
        case connectivity
        case inavalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result)-> Void) {
        client.get(from: url) { response in
            
            switch response {
            case .success(let data, let response):
                // Here we are capturing self.
                // We might have a retain cycle depanding on how the client is created.
                // But all the tests are passing -> we are not covering memory leaks.
                completion(self.map(data, from: response))
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, response: response)
            return .success(items)
            
        } catch {
            return .failure(.inavalidData)
        }
    }
}
