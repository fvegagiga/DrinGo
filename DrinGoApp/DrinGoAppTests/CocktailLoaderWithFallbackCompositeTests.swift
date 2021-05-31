//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed
import DrinGoApp

class CocktailLoaderWithFallbackCompositeTests: XCTestCase, CocktailLoaderTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueCocktail(id: 0)
        let fallbackFeed = uniqueCocktail(id: 1)
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }

    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueCocktail(id: 1)
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))

        expect(sut, toCompleteWith: .success(fallbackFeed))
    }

    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    // MARK: - Helpers
    
    private func makeSUT(primaryResult: CocktailLoader.Result, fallbackResult: CocktailLoader.Result, file: StaticString = #file, line: UInt = #line) -> CocktailLoader {
        let primaryLoader = CocktailLoaderStub(result: primaryResult)
        let fallbackLoader = CocktailLoaderStub(result: fallbackResult)
        let sut = CocktailLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
