//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedErrorViewModel {
    let message: String
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class CocktailFeedPresenter {
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        return NSLocalizedString("COCKTAIL_LIST_VIEW_TITLE",
                                 tableName: "CocktailFeed",
                                 bundle: Bundle(for: CocktailFeedPresenter.self),
                                 comment: "Title for the Cocktail list view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("COCKTAIL_LIST_VIEW_CONNECTION_ERROR",
             tableName: "CocktailFeed",
             bundle: Bundle(for: CocktailFeedPresenter.self),
             comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [CocktailItem]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
