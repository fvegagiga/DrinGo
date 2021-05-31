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


class CocktailLoaderCacheDecoratorTests: XCTestCase {

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
    
    // MARK: - Helpers
    
    private func expect(_ sut: CocktailLoader, toCompleteWith expectedResult: CocktailLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
                
        wait(for: [exp], timeout: 1.0)
    }
}
