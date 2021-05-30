//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

public class CocktailImageDataLoaderWithFallbackComposite: CocktailImageDataLoader {
    private let primary: CocktailImageDataLoader
    private let fallback: CocktailImageDataLoader
    
    public init(primary: CocktailImageDataLoader, fallback: CocktailImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    private class TaskWrapper: CocktailImageDataLoaderTask {
        var wrapped: CocktailImageDataLoaderTask?

        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }

        return task
    }
}
