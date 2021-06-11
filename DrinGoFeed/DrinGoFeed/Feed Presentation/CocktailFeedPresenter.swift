//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public final class CocktailFeedPresenter {
    
    public static var title: String {
        return NSLocalizedString("COCKTAIL_LIST_VIEW_TITLE",
            tableName: "CocktailFeed",
            bundle: Bundle(for: CocktailFeedPresenter.self),
            comment: "Title for the feed view")
    }
    
    public static func map(_ feed: [CocktailItem]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
