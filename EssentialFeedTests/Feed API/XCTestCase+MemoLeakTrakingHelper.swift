//
//  XCTestCase+MemoLeakTrakingHelper.swift
//  EssentialFeedTests
//
//  Created by Luca Gramaglia on 08/03/2020.
//  Copyright © 2020 lucagramaglia. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        // when every test finishing running, this block of code is invoked.
        addTeardownBlock { [weak instance] in
            // we need to make sure that instance of the object we are checking it's nil (deallocated from memory).
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
