//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class IngredientsPresenter {
    
    public static var title: String {
        NSLocalizedString("INGREDIENTS_VIEW_TITLE",
            tableName: "Ingredients",
            bundle: Bundle(for: Self.self),
            comment: "Title for the ingredients view")
    }
    
    public static func map(_ ingredients: [CocktailIngredient]) -> IngredientsViewModel {
        IngredientsViewModel(ingredients: ingredients.map { ingredient in
            IngredientViewModel(ingredient: ingredient.name, measure: ingredient.measure)
        })
    }
}
