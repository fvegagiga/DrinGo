//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

func uniqueCocktail(idx: Int) -> CocktailItem {
    return CocktailItem(id: idx, name: "any", description: "any", imageURL: anyURL(), ingredients: ["Ing1", "Ingr2"], quantity: ["Qt1", "Qt2"])
}

func uniqueCocktails() -> (models: [CocktailItem], local: [LocalCocktailItem]) {
    let models = [uniqueCocktail(idx: 0), uniqueCocktail(idx: 1)]
    let localItems = models.map { LocalCocktailItem(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL, ingredients: $0.ingredients, quantity: $0.quantity) }
    return (models, localItems)
}

extension Date {
    func minusCocktailCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
