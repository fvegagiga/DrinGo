//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation


public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class CocktailFeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public static var title: String {
        return NSLocalizedString("COCKTAIL_LIST_VIEW_TITLE",
            tableName: "CocktailFeed",
            bundle: Bundle(for: CocktailFeedPresenter.self),
            comment: "Title for the feed view")
    }
    
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
    
    public func didStartLoadingFeed() {
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
