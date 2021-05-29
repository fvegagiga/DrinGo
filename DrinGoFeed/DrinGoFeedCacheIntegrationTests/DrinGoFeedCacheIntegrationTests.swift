//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class DrinGoFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    // MARK: - LocalFeedLoader Tests
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeCocktailLoader()

        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeCocktailLoader()
        let sutToPerformLoad = makeCocktailLoader()
        let feed = uniqueCocktails().models
        
        save(feed, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeCocktailLoader()
        let sutToPerformLastSave = makeCocktailLoader()
        let sutToPerformLoad = makeCocktailLoader()
        let firstFeed = uniqueCocktails().models
        let latestFeed = uniqueCocktails().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeCocktailLoader()
        let feedLoaderToPerformValidation = makeCocktailLoader()
        let feed = uniqueCocktails().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: feed)
    }
    
    func test_validateFeedCache_deletesFeedSavedInADistantPast() {
        let feedLoaderToPerformSave = makeCocktailLoader(currentDate: .distantPast)
        let feedLoaderToPerformValidation = makeCocktailLoader(currentDate: Date())
        let feed = uniqueCocktails().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)

        expect(feedLoaderToPerformSave, toLoad: [])
    }

    
    // MARK: - LocalCocktailImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let cocktailLoader = makeCocktailLoader()
        let cocktail = uniqueCocktail()
        let dataToSave = anyData()
        
        save([cocktail], with: cocktailLoader)
        save(dataToSave, for: testSpecificFilePath(), with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: testSpecificFilePath())
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
        let imageLoaderToPerformFirstSave = makeImageLoader()
        let imageLoaderToPerformLastSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeCocktailLoader()
        let cocktail = uniqueCocktail()
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)
        
        save([cocktail], with: feedLoader)
        save(firstImageData, for: testSpecificFilePath(), with: imageLoaderToPerformFirstSave)
        save(lastImageData, for: testSpecificFilePath(), with: imageLoaderToPerformLastSave)

        expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: testSpecificFilePath())
    }

    
    // MARK: - Helpers
    private func makeCocktailLoader(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> LocalCocktailLoader {
        let storeURL = testSpecificStoreURL()
        let store = CodableFeedStore(storeURL: storeURL)
        let sut = LocalCocktailLoader(store: store, currentDate: { currentDate })

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalCocktailImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = CodableFeedStore(storeURL: storeURL)
        let sut = LocalCocktailImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ items: [CocktailItem], with loader: LocalCocktailLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(items) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
            saveExp.fulfill()
        }

        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func validateCache(with loader: LocalCocktailLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.validateCache() { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to validate feed successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    
    private func expect(_ sut: LocalCocktailLoader, toLoad expectedItems: [CocktailItem], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedItems):
                XCTAssertEqual(loadedItems, expectedItems, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func save(_ data: Data, for url: URL, with loader: LocalCocktailImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalCocktailImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func testSpecificFilePath() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).png")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
