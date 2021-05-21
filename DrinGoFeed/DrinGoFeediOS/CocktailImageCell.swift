//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit

public final class CocktailFeedCell: UITableViewCell {
    public let titleLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let cocktailImageContainer = UIView()
    public let cocktailImageView = UIImageView()
    
    private(set) public lazy var cocktailImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }

}
