//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit

final class CocktailFeedCellController {
    private let viewModel: CocktailImageViewModel<UIImage>

    init(viewModel: CocktailImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(CocktailFeedCell())
        viewModel.loadImageData()

        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: CocktailFeedCell) -> CocktailFeedCell {
        cell.titleLabel.text = viewModel.title
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.cocktailImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.cocktailImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.cocktailImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }

}
