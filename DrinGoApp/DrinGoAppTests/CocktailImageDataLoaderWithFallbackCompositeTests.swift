//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CocktailImageDataLoaderWithFallbackComposite: CocktailImageDataLoader {
    private let primary: CocktailImageDataLoader
    
    init(primary: CocktailImageDataLoader, fallback: CocktailImageDataLoader) {
        self.primary = primary
    }

    private class Task: CocktailImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        _ = primary.loadImageData(from: url) { _ in }

        return Task()
    }
}

class CocktailImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = CocktailImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
        
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = CocktailImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    // MARK: - Helpers
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class LoaderSpy: CocktailImageDataLoader {
        private var messages = [(url: URL, completion: (CocktailImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }

        private struct Task: CocktailImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }

}
