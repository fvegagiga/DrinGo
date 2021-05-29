//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

extension CodableFeedStore: CocktailImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (CocktailImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (CocktailImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

class CodableCocktailImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func notFound() -> CocktailImageDataStore.RetrievalResult {
        return .success(.none)
    }

    private func expect(_ sut: CodableFeedStore, toCompleteRetrievalWith expectedResult: CocktailImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

}
