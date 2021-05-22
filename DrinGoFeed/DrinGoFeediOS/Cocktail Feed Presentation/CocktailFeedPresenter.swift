//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import DrinGoFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [CocktailItem]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class CocktailFeedPresenter {
    private let feedLoader: CocktailLoader
    
    init(feedLoader: CocktailLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
