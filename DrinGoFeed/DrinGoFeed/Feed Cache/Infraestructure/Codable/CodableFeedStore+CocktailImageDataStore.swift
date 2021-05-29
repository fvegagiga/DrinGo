//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

extension CodableFeedStore: CocktailImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (CocktailImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (CocktailImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
