//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class CocktailFeedCellController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private var cell: CocktailFeedCell?

    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
        
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    public func display(_ viewModel: CocktailImageViewModel<UIImage>) {
        cell?.titleLabel.text = viewModel.title
        cell?.descriptionLabel.text = viewModel.description
        cell?.cocktailImageView.setImageAnimated(viewModel.image)
        cell?.cocktailImageContainer.isShimmering = viewModel.isLoading
        cell?.cocktailImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
