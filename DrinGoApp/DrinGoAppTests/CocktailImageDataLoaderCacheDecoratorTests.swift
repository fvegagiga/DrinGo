//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed
import DrinGoApp

class CocktailImageDataLoaderCacheDecorator: CocktailImageDataLoader {
    private let decoratee: CocktailImageDataLoader
    
    init(decoratee: CocktailImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
}


class CocktailImageDataLoaderCacheDecoratorTests: XCTestCase, CocktailImageDataLoaderTestsCase {

    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()

        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs")
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load URL from loader")
    }

    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel URL loading from loader")
    }

    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let imageData = anyData()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            loader.complete(with: imageData)
        })
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            loader.complete(with: anyNSError())
        })
    }

    // MARK: - Helpers
        
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CocktailImageDataLoader, loader: CocktailImageDataLoaderSpy) {
        let loader = CocktailImageDataLoaderSpy()
        let sut = CocktailImageDataLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
}
