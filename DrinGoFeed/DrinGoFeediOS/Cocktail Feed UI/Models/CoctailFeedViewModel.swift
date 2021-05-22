//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

final class CocktailFeedViewModel {
    private let feedLoader: CocktailLoader
    
    init(feedLoader: CocktailLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((CocktailFeedViewModel) -> Void)?
    var onFeedLoad: (([CocktailItem]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
