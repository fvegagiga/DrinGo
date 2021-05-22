//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class CocktailFeedCellController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private lazy var cell = CocktailFeedCell()

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: CocktailImageViewModel<UIImage>) {

        cell.titleLabel.text = viewModel.title
        cell.descriptionLabel.text = viewModel.description
        cell.cocktailImageView.image = viewModel.image
        cell.cocktailImageContainer.isShimmering = viewModel.isLoading
        cell.cocktailImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = delegate.didRequestImage
    }

}
