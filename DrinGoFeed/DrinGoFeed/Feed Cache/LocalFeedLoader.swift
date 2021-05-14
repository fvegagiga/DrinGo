//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = CocktailLoader.Result
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ cocktails: [CocktailItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(cocktails, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .found(items, timestamp) where self.validate(timestamp):
                completion(.success(items.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
    
    private func cache(_ items: [CocktailItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == CocktailItem {
    func toLocal() -> [LocalCocktailItem] {
        return map { LocalCocktailItem(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL, ingredients: $0.ingredients, quantity: $0.quantity)
        }
    }
}
 
private extension Array where Element == LocalCocktailItem {
    func toModels() -> [CocktailItem] {
        return map { CocktailItem(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL, ingredients: $0.ingredients, quantity: $0.quantity)
        }
    }
}
