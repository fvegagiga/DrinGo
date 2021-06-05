// Copyright @ 2021 Fernando Vega. All rights reserved.

import Foundation

public final class RemoteCocktailIngredientsLoader: CocktailLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = CocktailLoader.Result
    
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
            let cocktails = try CocktailIngredientsMapper.map(data, response)
            return .success(cocktails.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteCocktailItem {
    func toModels() -> [CocktailItem] {
        return compactMap {
            guard let id = Int($0.idDrink) else { return nil }
            return CocktailItem(id: id,
                                name: $0.strDrink,
                                description: $0.strInstructions,
                                imageURL: URL(string: $0.strDrinkThumb)!,
                                ingredients: [$0.strIngredient1,
                                              $0.strIngredient2,
                                              $0.strIngredient3,
                                              $0.strIngredient4,
                                              $0.strIngredient5].compactMap({$0}),
                                quantity: [$0.strMeasure1,
                                           $0.strMeasure2,
                                           $0.strMeasure3,
                                           $0.strMeasure4,
                                           $0.strMeasure5].compactMap({$0}))
        }
    }
}
