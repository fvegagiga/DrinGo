//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public struct CocktailItem: Equatable {
    public let id: Int
    public let name: String
    public let description: String
    public let imageURL: URL
    public let ingredients: [String]
    public let quantity: [String]
    
    public init(id: Int, name: String, description: String, imageURL: URL, ingredients: [String], quantity: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.ingredients = ingredients
        self.quantity = quantity
    }
}
