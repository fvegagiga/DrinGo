//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import Combine
import DrinGoFeed
import DrinGoFeediOS

public final class CocktailUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[CocktailItem], Error>,
                                        imageLoader: @escaping (URL) -> CocktailImageDataLoader.Publisher) -> CocktailFeedViewController {
        
        let presentationAdapter = CocktailFeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
        let cocktailFeedController = makeWith(delegate: presentationAdapter, title: CocktailFeedPresenter.title)
        
        presentationAdapter.presenter = CocktailFeedPresenter(
            feedView: FeedViewAdapter(
                controller: cocktailFeedController,
                imageLoader: { imageLoader($0).dispatchOnMainQueue() }),
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
