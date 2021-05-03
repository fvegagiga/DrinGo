//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

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
                if let items = try? CocktailItemMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
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
        let id: Int
        let name: String
        let description: String
        let imageURL: URL
        let ingredient1: String?
        let ingredient2: String?
        let ingredient3: String?
        let ingredient4: String?
        let ingredient5: String?
        let quantity1: String?
        let quantity2: String?
        let quantity3: String?
        let quantity4: String?
        let quantity5: String?
        
        private enum CodingKeys: String, CodingKey {
            case id = "idDrink"
            case name = "strDrink"
            case description = "strInstructions"
            case imageURL = "strDrinkThumb"
            case ingredient1 = "strIngredient1"
            case ingredient2 = "strIngredient2"
            case ingredient3 = "strIngredient3"
            case ingredient4 = "strIngredient4"
            case ingredient5 = "strIngredient5"
            case quantity1 = "strMeasure1"
            case quantity2 = "strMeasure2"
            case quantity3 = "strMeasure3"
            case quantity4 = "strMeasure4"
            case quantity5 = "strMeasure5"
        }
        
        var drink: CocktailItem {
            CocktailItem(id: id,
                         name: name,
                         description: description,
                         imageURL: imageURL,
                         ingredients: [ingredient1,
                                       ingredient2,
                                       ingredient3,
                                       ingredient4,
                                       ingredient5].compactMap({$0}),
                         quantity: [quantity1,
                                    quantity2,
                                    quantity3,
                                    quantity4,
                                    quantity5].compactMap({$0}))
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [CocktailItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteCocktailLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
            
        return root.drinks.map { $0.drink }
    }
}
