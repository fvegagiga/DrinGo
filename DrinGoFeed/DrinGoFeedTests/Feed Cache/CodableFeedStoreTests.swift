//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableCocktailItem]
        let timestamp: Date
        
        var localCocktails: [LocalCocktailItem] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableCocktailItem: Codable {
        private let id: Int
        private let name: String
        private let description: String
        private let imageURL: URL
        private let ingredients: [String]
        private let quantity: [String]
        
        init(_ cocktail: LocalCocktailItem) {
            self.id = cocktail.id
            self.name = cocktail.name
            self.description = cocktail.description
            self.imageURL = cocktail.imageURL
            self.ingredients = cocktail.ingredients
            self.quantity = cocktail.quantity
        }
        
        var local: LocalCocktailItem {
            LocalCocktailItem(id: id, name: name, description: description, imageURL: imageURL, ingredients: ingredients, quantity: quantity)
        }
    }
    
    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localCocktails, timestamp: cache.timestamp))
    }
    
    func insert(_ cocktails: [LocalCocktailItem], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: cocktails.map(CodableCocktailItem.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()

            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedVAlues() {
        let sut = makeSUT()
        let cocktails = uniqueCocktails().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(cocktails, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(feed: retrievedCocktails, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrievedCocktails, cocktails)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                
                default:
                    XCTFail("Expected found result with feed \(cocktails) and timestamp \(timestamp), got \(retrieveResult) instead")
                }

                exp.fulfill()

            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
