//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

extension CodableFeedStore: CocktailImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (CocktailImageDataStore.InsertionResult) -> Void) {
        queue.async(flags: .barrier) {
            do {
                try data.write(to: url)
                completion(.success(()))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (CocktailImageDataStore.RetrievalResult) -> Void) {
        queue.async {
            guard let data = try? Data(contentsOf: url) else {
                return completion(.success(.none))
            }
            
            completion(.success(data))
        }
    }
}
