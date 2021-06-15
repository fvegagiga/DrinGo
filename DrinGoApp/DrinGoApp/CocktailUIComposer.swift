//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import Combine
import DrinGoFeed
import DrinGoFeediOS

public final class CocktailUIComposer {
    private init() {}
    
    private typealias CocktailPresentationAdapter = LoadResourcePresentationAdapter<[CocktailItem], CocktailFeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[CocktailItem], Error>,
        imageLoader: @escaping (URL) -> CocktailImageDataLoader.Publisher,
        selection: @escaping (CocktailItem) -> Void = { _ in }
    ) -> ListViewController {
        
        let presentationAdapter = CocktailPresentationAdapter(loader: feedLoader)
        
        let cocktailFeedController = makeWith(title: CocktailFeedPresenter.title)
        cocktailFeedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResoucePresenter(
            resourceView: CocktailFeedViewAdapter(
                controller: cocktailFeedController,
                imageLoader: imageLoader,
                selection: selection),
            loadingView: WeakRefVirtualProxy(cocktailFeedController),
            errorView: WeakRefVirtualProxy(cocktailFeedController),
            mapper: CocktailFeedPresenter.map)
        
        return cocktailFeedController
    }

    private static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "CocktailFeed", bundle: bundle)
        let cocktailFeedController = storyboard.instantiateInitialViewController() as! ListViewController
        cocktailFeedController.title = title
        return cocktailFeedController
    }
}
