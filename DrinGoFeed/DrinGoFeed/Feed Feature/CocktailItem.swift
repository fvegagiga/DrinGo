//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public struct CocktailItem: Equatable {
    let id: Int
    let name: String
    let description: String
    let imageURL: URL
    let ingredients: [String]
    let quantity: [String]
}
