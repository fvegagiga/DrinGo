//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import Combine
import DrinGoFeed
import DrinGoFeediOS

public final class IngredientsUIComposer {
    private init() {}
    
    private typealias CocktailPresentationAdapter = LoadResourcePresentationAdapter<[CocktailItem], FeedViewAdapter>
    
    public static func ingredientsComposedWith(
        ingredientsLoader: @escaping () -> AnyPublisher<[CocktailItem], Error>
    ) -> ListViewController {
        
        let presentationAdapter = CocktailPresentationAdapter(loader: ingredientsLoader)
        let cocktailFeedController = makeWith(title: CocktailFeedPresenter.title)
        cocktailFeedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResoucePresenter(
            resourceView: FeedViewAdapter(
                controller: cocktailFeedController,
                imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
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
