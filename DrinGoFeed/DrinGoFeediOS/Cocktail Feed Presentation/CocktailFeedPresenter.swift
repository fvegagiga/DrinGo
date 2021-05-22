//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import DrinGoFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [CocktailItem])
}

final class CocktailFeedPresenter {
    private let feedLoader: CocktailLoader
    
    init(feedLoader: CocktailLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
