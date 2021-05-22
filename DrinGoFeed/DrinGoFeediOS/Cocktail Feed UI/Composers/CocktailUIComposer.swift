//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public final class CocktailUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: CocktailLoader, imageLoader: CocktailImageDataLoader) -> CocktailFeedViewController {
        let presenter = CocktailFeedPresenter()
        let presentationAdapter = CocktailFeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)

        let cocktailFeedController = CocktailFeedViewController(refreshController: refreshController)
        
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: cocktailFeedController, imageLoader: imageLoader)

        return cocktailFeedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: CocktailFeedViewController?
    private let imageLoader: CocktailImageDataLoader
    
    init(controller: CocktailFeedViewController, imageLoader: CocktailImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            CocktailFeedCellController(viewModel: CocktailImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}

private final class CocktailFeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: CocktailLoader
    private let presenter: CocktailFeedPresenter
    
    init(feedLoader: CocktailLoader, presenter: CocktailFeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }

    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
