// Copyright @ 2021 Fernando Vega. All rights reserved.

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public final class LoadResoucePresenter {
    public typealias Mapper = (String) -> String
    
    private let resourceView: ResourceView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper
        
    public var feedLoadError: String {
        return NSLocalizedString("COCKTAIL_LIST_VIEW_CONNECTION_ERROR",
            tableName: "CocktailFeed",
            bundle: Bundle(for: CocktailFeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }

    public init(resourceView: ResourceView, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
        
    public func didFinishLoading(with resource: String) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
