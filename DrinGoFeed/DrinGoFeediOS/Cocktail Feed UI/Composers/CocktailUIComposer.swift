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
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: cocktailFeedController, loader: imageLoader)
        
        return cocktailFeedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: CocktailFeedViewController, loader: CocktailImageDataLoader) -> ([CocktailItem]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                CocktailFeedCellController(model: model, imageLoader: loader)
            }
        }
    }
}
