//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

public final class CocktailImageDataLoaderCacheDecorator: CocktailImageDataLoader {
    private let decoratee: CocktailImageDataLoader
    private let cache: CocktailImageDataCache

    public init(decoratee: CocktailImageDataLoader, cache: CocktailImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save((try? result.get()) ?? Data(), for: url) { _ in }
                return data
            })
        }
    }
}
