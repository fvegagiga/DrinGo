//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import DrinGoFeed

final class CocktailFeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: CocktailLoader
    var presenter: CocktailFeedPresenter?
    
    init(feedLoader: CocktailLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
