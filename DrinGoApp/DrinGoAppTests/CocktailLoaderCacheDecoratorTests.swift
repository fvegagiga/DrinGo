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
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(loaderResult: CocktailLoader.Result, file: StaticString = #file, line: UInt = #line) -> CocktailLoader {
        let loader = CocktailLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

}
