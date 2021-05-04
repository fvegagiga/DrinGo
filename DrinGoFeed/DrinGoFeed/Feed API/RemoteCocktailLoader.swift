//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class RemoteCocktailLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = Swift.Result<[CocktailItem], Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                completion(CocktailItemMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
