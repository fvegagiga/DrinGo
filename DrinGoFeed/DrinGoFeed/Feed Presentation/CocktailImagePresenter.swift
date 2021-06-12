//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class CocktailImagePresenter {
    
    public static func map(_ cocktail: CocktailItem) -> CocktailImageViewModel {
        CocktailImageViewModel(title: cocktail.name,
                               description: cocktail.description)
    }
}
