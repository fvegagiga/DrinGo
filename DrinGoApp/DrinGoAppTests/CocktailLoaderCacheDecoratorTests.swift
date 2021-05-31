//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

final class FeedLoaderCacheDecorator: CocktailLoader {
    private let decoratee: CocktailLoader
    
    init(decoratee: CocktailLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (CocktailLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}


class CocktailLoaderCacheDecoratorTests: XCTestCase, CocktailLoaderTestCase {

    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueCocktail()
        let loader = CocktailLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let loader = CocktailLoaderStub(result: .failure(anyNSError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
}
