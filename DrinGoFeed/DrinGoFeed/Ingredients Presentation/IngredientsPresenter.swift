//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class IngredientsPresenter {
    
    public static var title: String {
        return NSLocalizedString("INGREDIENTS_VIEW_TITLE",
            tableName: "Ingredients",
            bundle: Bundle(for: Self.self),
            comment: "Title for the ingredients view")
    }
}
