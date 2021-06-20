//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public protocol CocktailImageDataLoaderTask {
    func cancel()
}

public protocol CocktailImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> CocktailImageDataLoaderTask
}
