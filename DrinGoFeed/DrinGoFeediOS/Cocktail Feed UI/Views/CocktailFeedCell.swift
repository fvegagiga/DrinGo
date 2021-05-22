//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit

public final class CocktailFeedCell: UITableViewCell {
    @IBOutlet private(set) public var titleLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var cocktailImageContainer: UIView!
    @IBOutlet private(set) public var cocktailImageView: UIImageView!
    @IBOutlet private(set) public var cocktailImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
