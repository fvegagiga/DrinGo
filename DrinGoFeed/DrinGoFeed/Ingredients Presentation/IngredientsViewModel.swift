//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public struct IngredientsViewModel {
    public let ingredients: [IngredientViewModel]
}

public struct IngredientViewModel: Hashable {
    public let ingredient: String
    public let measure: String
    
    public init(ingredient: String, measure: String) {
        self.ingredient = ingredient
        self.measure = measure
    }
}
