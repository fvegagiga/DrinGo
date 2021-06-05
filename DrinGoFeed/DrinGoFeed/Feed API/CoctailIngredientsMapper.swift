//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

final class CocktailIngredientsMapper {
    private struct Root: Decodable {
        let drinks: [RemoteCocktailItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteCocktailItem] {
        guard isOK(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCocktailIngredientsLoader.Error.invalidData
        }
        
        return root.drinks
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
