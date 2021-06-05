//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public struct CocktailIngredient: Equatable {
    public let name: String
    public let measure: String
    
    public init(name: String, measure: String) {
        self.name = name
        self.measure = measure
    }
}
