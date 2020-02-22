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

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
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
                
                do {
                    let items = try FeedItemMapper.map(data, response: response)
                    completion(.success(items))
                    
                } catch {
                    completion(.failure(.inavalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [Item]
    }

    // This is the internal representation of the feed item for the API Module.

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.inavalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}

