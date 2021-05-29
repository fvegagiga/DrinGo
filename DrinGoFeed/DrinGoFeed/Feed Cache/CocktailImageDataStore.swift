//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public protocol CocktailImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
