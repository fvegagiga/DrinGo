// Copyright @ 2021 Fernando Vega. All rights reserved.

import Foundation

public final class RemoteCocktailIngredientsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = Swift.Result<[CocktailIngredient], Swift.Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteCocktailIngredientsLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let ingredients = try CocktailIngredientsMapper.map(data, response)
            return .success(ingredients)
        } catch {
            return .failure(error)
        }
    }
}
