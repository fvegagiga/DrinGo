//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed
import DrinGoFeediOS

public final class CocktailUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: CocktailLoader, imageLoader: CocktailImageDataLoader) -> CocktailFeedViewController {
        let presentationAdapter = CocktailFeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let cocktailFeedController = makeWith(delegate: presentationAdapter, title: CocktailFeedPresenter.title)
        
        presentationAdapter.presenter = CocktailFeedPresenter(
            feedView: FeedViewAdapter(
                controller: cocktailFeedController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(cocktailFeedController),
            errorView: WeakRefVirtualProxy(cocktailFeedController)
        )

        return cocktailFeedController
    }

    private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> CocktailFeedViewController {
        let bundle = Bundle(for: CocktailFeedViewController.self)
        let storyboard = UIStoryboard(name: "CocktailFeed", bundle: bundle)
        let cocktailFeedController = storyboard.instantiateInitialViewController() as! CocktailFeedViewController
        cocktailFeedController.delegate = delegate
        cocktailFeedController.title = title
        return cocktailFeedController
    }
}
