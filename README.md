# EssentialFeed
Studying Project using TDD methodology.

This simple app just displayes data as a feed.
It is created using the TDD methodology.

It is currently composed of a "Cocoa Framework" so that the UI, that is going to live in the iOS Target, is separated.
By doing this, tests are faster to execute because there is no need of the iOS simulator.

**FeedLoader** is the interface that separates the modules of the app.

**RemoteFeedLoader** implements "FeedLoader" and it's not depending on a concrate type (URLSession) but on an injected dependency called "HTTPClient". By doing this "RemoteFeedLoader" is open for extensions and more testable.

**HTTPClient** is a protocol / contract that will be extend by the concrete classes that will use URLSession / Alamofire to actually do the HTTP Network calls. In this project "URLSessionHTTPClient" extends "HTTPClient".

**URLSessionHTTPClient** is the concrete class that is using Apple's "URLSession" to get the data to display as a feed.

*Last Version*
"CI" Scheme that is used by Trevis CI to run end to end / unit test every time there is a new commit on the repository.
