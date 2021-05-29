//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class RemoteCocktailImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: CocktailImageDataLoaderTask {
        private var completion: ((CocktailImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (CocktailImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: CocktailImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))

                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
                
            case let .failure(error): task.complete(with: .failure(error))
            }
        }
        
        return task
    }
}