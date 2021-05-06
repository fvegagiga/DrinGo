//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

final class CocktailItemMapper {
    private struct Root: Decodable {
        let drinks: [Drink]
        
        var feed: [CocktailItem] {
            return drinks.compactMap { $0.drink }
        }
    }

    private struct Drink: Decodable {
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
        
        var drink: CocktailItem? {
            guard let id = Int(idDrink) else { return nil }
            return CocktailItem(id: id,
                                name: strDrink,
                                description: strInstructions,
                                imageURL: URL(string: strDrinkThumb)!,
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
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteCocktailLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteCocktailLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}