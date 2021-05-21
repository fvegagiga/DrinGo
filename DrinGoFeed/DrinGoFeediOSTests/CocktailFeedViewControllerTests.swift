//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import UIKit
import DrinGoFeed

final class CocktailFeedViewController: UIViewController {
    private var loader: CocktailLoader?

    convenience init(loader: CocktailLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load() { _ in }
    }
}

class CocktailFeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = CocktailFeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = CocktailFeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers
    
    class LoaderSpy: CocktailLoader {
        private (set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (CocktailLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
