//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public final class CocktailUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: CocktailLoader, imageLoader: CocktailImageDataLoader) -> CocktailFeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let cocktailFeedController = CocktailFeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak cocktailFeedController] feed in
            cocktailFeedController?.tableModel = feed.map { model in
                CocktailFeedCellController(model: model, imageLoader: imageLoader)
            }
        }
        
        return cocktailFeedController
    }
}
