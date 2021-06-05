//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

final class CocktailIngredientsMapper {
    private struct Root: Decodable {
        private let drinks: [Item]
        
        private struct Item: Decodable {
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
        
        var ingredients: [CocktailIngredient] {
            guard let item = drinks.first else { return [] }
            
            let ingredients = [item.strIngredient1,
                               item.strIngredient2,
                               item.strIngredient3,
                               item.strIngredient4,
                               item.strIngredient5]
            
            let measures = [item.strMeasure1,
                            item.strMeasure2,
                            item.strMeasure3,
                            item.strMeasure4,
                            item.strMeasure5]
            
            let items: [CocktailIngredient] = zip(ingredients, measures).compactMap {
                guard let name = $0.0 else { return nil }
                return CocktailIngredient(name: name, measure: $0.1 ?? "")
            }
            
            return items
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [CocktailIngredient] {
        guard isOK(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCocktailIngredientsLoader.Error.invalidData
        }
        
        return root.ingredients
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
