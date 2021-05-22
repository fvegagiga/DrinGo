//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public final class CocktailUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: CocktailLoader, imageLoader: CocktailImageDataLoader) -> CocktailFeedViewController {
        let cocktailFeedViewModel = CocktailFeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: cocktailFeedViewModel)

        let cocktailFeedController = CocktailFeedViewController(refreshController: refreshController)
        
        cocktailFeedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: cocktailFeedController, loader: imageLoader)
        
        return cocktailFeedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: CocktailFeedViewController, loader: CocktailImageDataLoader) -> ([CocktailItem]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                let viewModel = CocktailImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                return CocktailFeedCellController(viewModel: viewModel)
            }
        }
    }
}
