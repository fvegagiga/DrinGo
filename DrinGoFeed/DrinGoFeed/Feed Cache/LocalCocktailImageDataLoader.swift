//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class LocalCocktailImageDataLoader: CocktailImageDataLoader {
    
    private let store: CocktailImageDataStore
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    public init(store: CocktailImageDataStore) {
        self.store = store
    }
    
    private final class Task: CocktailImageDataLoaderTask {
        private var completion: ((CocktailImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (CocktailImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: CocktailImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public typealias SaveResult = Result<Void, Swift.Error>

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { _ in }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        let task = Task(completion)

        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                            .mapError { _ in Error.failed }
                            .flatMap { data in
                                data.map { .success($0) } ?? .failure(Error.notFound)
                            })
        }

        return task
    }
}
