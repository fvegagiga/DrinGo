//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

final class CocktailFeedViewModel {
    typealias Observer<T> = (T) -> Void

    private let feedLoader: CocktailLoader
    
    init(feedLoader: CocktailLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[CocktailItem]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
