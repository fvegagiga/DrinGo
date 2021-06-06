//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

class CocktailLoaderStub {
    private let result: Swift.Result<[CocktailItem], Error>
    
    init(result: Swift.Result<[CocktailItem], Error>) {
        self.result = result
    }

    func load(completion: @escaping (Swift.Result<[CocktailItem], Error>) -> Void) {
        completion(result)
    }
}
