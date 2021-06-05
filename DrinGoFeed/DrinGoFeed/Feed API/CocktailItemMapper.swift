//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

final class CocktailItemMapper {
    private struct Root: Decodable {
        private let drinks: [RemoteCocktailItem]
        
        private struct RemoteCocktailItem: Decodable {
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

        var items: [CocktailItem] {
            drinks.compactMap {
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
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [CocktailItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCocktailLoader.Error.invalidData
        }
        
        return root.items
    }
}
