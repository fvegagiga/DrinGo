//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

protocol CocktailImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}


final class LocalCocktailImageDataLoader: CocktailImageDataLoader {
    private struct Task: CocktailImageDataLoaderTask {
        func cancel() {}
    }
    
    private let store: CocktailImageDataStore
    
    public enum Error: Swift.Error {
        case failed
    }
    
    init(store: CocktailImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            completion(.failure(Error.failed))
        }

        return Task()
    }
}


class LocalCocktailImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }

    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        })
    }

    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalCocktailImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalCocktailImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalCocktailImageDataLoader, toCompleteWith expectedResult: CocktailImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case (.failure(let receivedError as LocalCocktailImageDataLoader.Error),
                  .failure(let expectedError as LocalCocktailImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }

    
    private func failed() -> CocktailImageDataLoader.Result {
        return .failure(LocalCocktailImageDataLoader.Error.failed)
    }

    private class StoreSpy: CocktailImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private var completions = [(CocktailImageDataStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (CocktailImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
