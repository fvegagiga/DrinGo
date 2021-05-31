//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

class CocktailImageDataLoaderSpy: CocktailImageDataLoader {
    private var messages = [(url: URL, completion: (CocktailImageDataLoader.Result) -> Void)]()

    private(set) var cancelledURLs = [URL]()

    var loadedURLs: [URL] {
        return messages.map { $0.url }
    }

    private struct Task: CocktailImageDataLoaderTask {
        let callback: () -> Void
        func cancel() { callback() }
    }

    func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
