//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public protocol CocktailImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
