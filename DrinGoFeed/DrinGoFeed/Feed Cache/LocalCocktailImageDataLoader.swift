//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class LocalCocktailImageDataLoader {
    private let store: CocktailImageDataStore
    
    public init(store: CocktailImageDataStore) {
        self.store = store
    }
}

extension LocalCocktailImageDataLoader: CocktailImageDataCache {
    public typealias SaveResult = Result<Void, Swift.Error>

    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }

            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalCocktailImageDataLoader: ImageDataLoader {
    public typealias LoadResult = ImageDataLoader.Result
    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    private final class LoadImageDataTask: ImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        let task = LoadImageDataTask(completion)

        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                            .mapError { _ in LoadError.failed }
                            .flatMap { data in
                                data.map { .success($0) } ?? .failure(LoadError.notFound)
                            })
        }

        return task
    }
}
