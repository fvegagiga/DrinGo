//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed
import DrinGoApp

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
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueCocktail()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }

    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)

        sut.load { _ in }

        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache feed on load error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(loaderResult: CocktailLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> CocktailLoader {
        let loader = CocktailLoaderStub(result: loaderResult)
        let sut = CocktailLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: CocktailCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([CocktailItem])
        }
        
        func save(_ feed: [CocktailItem], completion: @escaping (CocktailCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }

}