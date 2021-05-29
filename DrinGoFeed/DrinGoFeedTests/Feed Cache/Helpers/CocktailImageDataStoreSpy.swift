//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

final class CocktailImageDataStoreSpy: CocktailImageDataStore {
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }

    private(set) var receivedMessages = [Message]()
    private var retrievalCompletions = [(CocktailImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(CocktailImageDataStore.InsertionResult) -> Void]()
    
    func insert(_ data: Data, for url: URL, completion: @escaping (CocktailImageDataStore.InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func retrieve(dataForURL url: URL, completion: @escaping (CocktailImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
