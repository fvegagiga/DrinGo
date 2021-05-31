// Copyright @ 2021 Fernando Vega. All rights reserved.

import Foundation

public protocol CocktailCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [CocktailItem], completion: @escaping (Result) -> Void)
}
