//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class CocktailIngredientsMapper {
    private struct Root: Decodable {
        private let drinks: [Item]
        
        private struct Item: Decodable {
            let strIngredient1: String?
            let strIngredient2: String?
            let strIngredient3: String?
            let strIngredient4: String?
            let strIngredient5: String?
            let strIngredient6: String?
            let strIngredient7: String?
            let strIngredient8: String?
            let strMeasure1: String?
            let strMeasure2: String?
            let strMeasure3: String?
            let strMeasure4: String?
            let strMeasure5: String?
            let strMeasure6: String?
            let strMeasure7: String?
            let strMeasure8: String?
        }
        
        var ingredients: [CocktailIngredient] {
            guard let item = drinks.first else { return [] }
            
            let ingredients = [item.strIngredient1,
                               item.strIngredient2,
                               item.strIngredient3,
                               item.strIngredient4,
                               item.strIngredient5,
                               item.strIngredient6,
                               item.strIngredient7,
                               item.strIngredient8]
            
            let measures = [item.strMeasure1,
                            item.strMeasure2,
                            item.strMeasure3,
                            item.strMeasure4,
                            item.strMeasure5,
                            item.strMeasure6,
                            item.strMeasure7,
                            item.strMeasure8]
            
            let items: [CocktailIngredient] = zip(ingredients, measures).compactMap {
                guard let name = $0.0 else { return nil }
                return CocktailIngredient(name: name, measure: $0.1 ?? "")
            }
            
            return items
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CocktailIngredient] {
        guard isOK(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.ingredients
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
