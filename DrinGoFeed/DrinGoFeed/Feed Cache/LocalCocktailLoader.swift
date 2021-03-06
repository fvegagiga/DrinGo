//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class LocalCocktailLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalCocktailLoader: CocktailCache {
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ cocktails: [CocktailItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(cocktails, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ items: [CocktailItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            
            completion(insertionResult)
        }
    }
}

extension LocalCocktailLoader {
    public typealias LoadResult = Swift.Result<[CocktailItem], Error>
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(cache)) where CocktailCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success(.some), .success(.none):
                completion(.success([]))
            }
        }
    }
}

extension LocalCocktailLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
                
            case let .success(.some(cache)) where !CocktailCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == CocktailItem {
    func toLocal() -> [LocalCocktailItem] {
        return map { LocalCocktailItem(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL)
        }
    }
}
 
private extension Array where Element == LocalCocktailItem {
    func toModels() -> [CocktailItem] {
        return map { CocktailItem(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL)
        }
    }
}
