//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest

final class CocktailFeedViewController {
    init(loader: CocktailFeedViewControllerTests.LoaderSpy) {
        
    }
}

class CocktailFeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = CocktailFeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    // MARK: - Helpers
    
    class LoaderSpy {
        private (set) var loadCallCount: Int = 0
    }
}
