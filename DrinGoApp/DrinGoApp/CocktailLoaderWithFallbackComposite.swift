//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import DrinGoFeed

public class CocktailLoaderWithFallbackComposite: CocktailLoader {
    private let primary: CocktailLoader
    private let fallback: CocktailLoader

    public init(primary: CocktailLoader, fallback: CocktailLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (CocktailLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }

    }
}
