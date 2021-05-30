//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CocktailLoaderWithFallbackComposite: CocktailLoader {
    private let primary: CocktailLoader

    init(primary: CocktailLoader, fallback: CocktailLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (CocktailLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class CocktailLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueCocktail(id: 0)
        let fallbackFeed = uniqueCocktail(id: 1)
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = CocktailLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
                
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers
    
    func uniqueCocktail(id: Int = 0) -> [CocktailItem] {
        return [CocktailItem(id: id, name: "any", description: "any", imageURL: anyURL(), ingredients: ["Ing1", "Ingr2"], quantity: ["Qt1", "Qt2"])]
    }

    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class LoaderStub: CocktailLoader {
        private let result: CocktailLoader.Result
        
        init(result: CocktailLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (CocktailLoader.Result) -> Void) {
            completion(result)
        }
    }

}
