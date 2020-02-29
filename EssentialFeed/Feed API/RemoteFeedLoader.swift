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

public class RemoteFeedLoader: FeedLoader {
    
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
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result)-> Void) {
        client.get(from: url) { [weak self] response in
            
            // this is to prevent the completion block to be called after client
            // instance has been deallocated.
            
            guard self != nil else { return }
            
            switch response {
            case .success(let data, let response):
                // By using the static "FeedItemMapper". Even if the instance of "RemoteFeedLoader"
                // has been deallocated, the completion block will be executed.
                // This is because we don't know the implementation of the Client, maybe its a Singleton,
                // and it leaves longer than the "RemoteFeedLoader".
                // This might be a bug, because the consumer of this "RemoteFeedLoader", they not expect
                // the completion block to be invoked, after the instance has been deallocated.
                // ** We must instruct the "RemoteFeedLoader" to prevent this problem **
                completion(FeedItemMapper.map(data, from: response))
                
            case .failure:
                // "Error.connectivity" its the domain-level error
                completion(.failure(Error.connectivity))
            }
        }
    }
}
