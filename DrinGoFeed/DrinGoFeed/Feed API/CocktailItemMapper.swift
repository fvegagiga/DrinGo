//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

struct RemoteCocktailItem: Decodable {
    let idDrink: String
    let strDrink: String
    let strInstructions: String
    let strDrinkThumb: String
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
}

final class CocktailItemMapper {
    private struct Root: Decodable {
        let drinks: [RemoteCocktailItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteCocktailItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCocktailLoader.Error.invalidData
        }
        
        return root.drinks
    }
}
