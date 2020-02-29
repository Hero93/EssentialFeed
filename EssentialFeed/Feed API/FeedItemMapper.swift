//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Luca Gramaglia on 25/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import Cocoa

internal final class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            return items.map { $0.item }
        }
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
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.inavalidData)
        }
        
        return .success(root.feed)
    }
}
