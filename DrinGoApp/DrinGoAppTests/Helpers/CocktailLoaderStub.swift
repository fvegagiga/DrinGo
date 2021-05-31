//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

class CocktailLoaderStub: CocktailLoader {
    private let result: CocktailLoader.Result
    
    init(result: CocktailLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (CocktailLoader.Result) -> Void) {
        completion(result)
    }
}
