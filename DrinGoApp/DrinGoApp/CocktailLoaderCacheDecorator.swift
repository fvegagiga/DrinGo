// Copyright @ 2021 Fernando Vega. All rights reserved.

import Foundation
import DrinGoFeed

public final class CocktailLoaderCacheDecorator: CocktailLoader {
    private let decoratee: CocktailLoader
    private let cache: CocktailCache
    
    public init(decoratee: CocktailLoader, cache: CocktailCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (CocktailLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.save(feed) { _ in }
                return feed
            })
        }
    }
}
