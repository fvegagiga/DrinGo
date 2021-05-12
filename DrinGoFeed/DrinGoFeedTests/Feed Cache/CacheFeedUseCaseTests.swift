//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
    
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
