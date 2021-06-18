//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class CocktailItemMapper {
    private struct Root: Decodable {
        private let drinks: [RemoteCocktailItem]
        
        private struct RemoteCocktailItem: Decodable {
            let idDrink: String
            let strDrink: String
            let strInstructions: String
            let strDrinkThumb: String
        }

        var items: [CocktailItem] {
            drinks.compactMap {
                guard let id = Int($0.idDrink) else { return nil }
                
                return CocktailItem(id: id,
                                    name: $0.strDrink,
                                    description: $0.strInstructions,
                                    imageURL: URL(string: $0.strDrinkThumb)!)
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CocktailItem] {
        guard isOK(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == 200
    }
}
