//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

final class CocktailItemMapper {
    private struct Root: Decodable {
        let drinks: [RemoteCocktailItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteCocktailItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCocktailLoader.Error.invalidData
        }
        
        return root.drinks
    }
}
