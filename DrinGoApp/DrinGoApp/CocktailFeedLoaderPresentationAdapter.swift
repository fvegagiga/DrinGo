//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Combine
import DrinGoFeed
import DrinGoFeediOS

final class CocktailFeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> AnyPublisher<[CocktailItem], Error>
    private var cancellable: Cancellable?
    var presenter: CocktailFeedPresenter?
    
    init(feedLoader: @escaping () -> AnyPublisher<[CocktailItem], Error>) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
            
        }, receiveValue: { [weak self] cocktails in
            self?.presenter?.didFinishLoadingFeed(with: cocktails)
        })
    }
}
