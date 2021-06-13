//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import Combine
import DrinGoFeed
import DrinGoFeediOS

public final class CocktailUIComposer {
    private init() {}
    
    private typealias CocktailPresentationAdapter = LoadResourcePresentationAdapter<[CocktailItem], FeedViewAdapter>
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[CocktailItem], Error>,
                                        imageLoader: @escaping (URL) -> CocktailImageDataLoader.Publisher) -> ListViewController {
        
        let presentationAdapter = CocktailPresentationAdapter(loader: { feedLoader().dispatchOnMainQueue() })
        let cocktailFeedController = makeWith(delegate: presentationAdapter, title: CocktailFeedPresenter.title)
        
        presentationAdapter.presenter = LoadResoucePresenter(
            resourceView: FeedViewAdapter(
                controller: cocktailFeedController,
                imageLoader: { imageLoader($0).dispatchOnMainQueue() }),
            loadingView: WeakRefVirtualProxy(cocktailFeedController),
            errorView: WeakRefVirtualProxy(cocktailFeedController),
            mapper: CocktailFeedPresenter.map)

        return cocktailFeedController
    }

    private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "CocktailFeed", bundle: bundle)
        let cocktailFeedController = storyboard.instantiateInitialViewController() as! ListViewController
        cocktailFeedController.delegate = delegate
        cocktailFeedController.title = title
        return cocktailFeedController
    }
}
