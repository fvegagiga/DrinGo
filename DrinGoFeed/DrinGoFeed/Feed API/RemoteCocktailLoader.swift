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


private class CocktailItemMapper {
    private struct Root: Decodable {
        let drinks: [Drink]
    }

    private struct Drink: Decodable {
        let idDrink: Int
        let strDrink: String
        let strInstructions: String
        let strDrinkThumb: URL
        let strIngredient1: String?
        let strIngredient2: String?
        let strIngredient3: String?
        let strIngredient4: String?
        let strIngredient5: String?
        let strMeasure1: String?
        let strMeasure2: String?
        let strMeasure3: String?
        let strMeasure4: String?
        let strMeasure5: String?
        
        var drink: CocktailItem {
            CocktailItem(id: idDrink,
                         name: strDrink,
                         description: strInstructions,
                         imageURL: strDrinkThumb,
                         ingredients: [strIngredient1,
                                       strIngredient2,
                                       strIngredient3,
                                       strIngredient4,
                                       strIngredient5].compactMap({$0}),
                         quantity: [strMeasure1,
                                    strMeasure2,
                                    strMeasure3,
                                    strMeasure4,
                                    strMeasure5].compactMap({$0}))
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteCocktailLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteCocktailLoader.Error.invalidData)
        }
        
        return .success(root.drinks.map { $0.drink })
    }
}
