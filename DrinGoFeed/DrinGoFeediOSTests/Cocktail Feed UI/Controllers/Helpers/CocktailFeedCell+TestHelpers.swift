//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeediOS

extension CocktailFeedCell {
    func simulateRetryAction() {
        cocktailImageRetryButton.simulateTap()
    }

    var isShowingImageLoadingIndicator: Bool {
        return cocktailImageContainer.isShimmering
    }

    var isShowingRetryAction: Bool {
        return !cocktailImageRetryButton.isHidden
    }
    
    var titleText: String? {
        return titleLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data? {
        return cocktailImageView.image?.pngData()
    }
}
