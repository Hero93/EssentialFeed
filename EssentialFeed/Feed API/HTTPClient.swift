//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Luca Gramaglia on 25/02/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import Cocoa

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
