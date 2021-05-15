//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeletesCacheOnLessThanSevenDaysOldCache() {
        let feed = uniqueCocktails()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func uniqueCocktail(idx: Int) -> CocktailItem {
        return CocktailItem(id: idx, name: "any", description: "any", imageURL: anyURL(), ingredients: ["Ing1", "Ingr2"], quantity: ["Qt1", "Qt2"])
    }
    
    func uniqueCocktails() -> (models: [CocktailItem], local: [LocalCocktailItem]) {
        let models = [uniqueCocktail(idx: 0), uniqueCocktail(idx: 1)]
        let localItems = models.map { LocalCocktailItem(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL, ingredients: $0.ingredients, quantity: $0.quantity) }
        return (models, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
