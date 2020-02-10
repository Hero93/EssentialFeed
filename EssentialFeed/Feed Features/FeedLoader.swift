//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Luca LG. Gramaglia on 10/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
