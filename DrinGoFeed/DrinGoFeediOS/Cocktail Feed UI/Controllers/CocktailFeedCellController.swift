//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

final class CocktailFeedCellController {
    private var task: CocktailImageDataLoaderTask?
    private let model: CocktailItem
    private let imageLoader: CocktailImageDataLoader
    
    init(model: CocktailItem, imageLoader: CocktailImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = CocktailFeedCell()
        cell.titleLabel.text = model.name
        cell.descriptionLabel.text = model.description
        cell.cocktailImageView.image = nil
        cell.cocktailImageRetryButton.isHidden = true
        cell.cocktailImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImageData(from: self.model.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.cocktailImageView.image = image
                cell?.cocktailImageRetryButton.isHidden = (image != nil)
                cell?.cocktailImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL) { _ in }
    }
    
    deinit {
        task?.cancel()
    }
}
