// Copyright @ 2021 Fernando Vega. All rights reserved.

import Foundation

public final class LoadResoucePresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
        
    public var feedLoadError: String {
        return NSLocalizedString("COCKTAIL_LIST_VIEW_CONNECTION_ERROR",
            tableName: "CocktailFeed",
            bundle: Bundle(for: CocktailFeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }

    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
        
    public func didFinishLoadingFeed(with feed: [CocktailItem]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
