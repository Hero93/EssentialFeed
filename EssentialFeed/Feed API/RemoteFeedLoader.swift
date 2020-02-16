//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Luca LG. Gramaglia on 15/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import Foundation

// There's no reason to make the HTTPClient a singleton, apart from convenience to locate the instace directly.
// It doesn't need to be a class either, it is just a contract defining which external functionality the "RemoteFeedLoader" needs.

// We don't need to create a new type to conform to it, we can easily create an extension on URLSession or Alamofire.

// It's public because it can be implemented by external modules

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

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
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error)-> Void = { _ in }) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
