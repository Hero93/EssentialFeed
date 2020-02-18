//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Luca LG. Gramaglia on 10/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

// this "image" keypath string it's API specific. If it changes in the API, we might break other
// models that have nothing to do with the API.
// The problem is that I can only have one decodable extension per module.

// The solution is to create another object that represents the transitional data of a FeedItem.
// From "FeedItem" API representation to a "FeedItem".

extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
