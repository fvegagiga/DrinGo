//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import DrinGoFeed
import DrinGoFeediOS

final class CocktailImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: CocktailItem
    private let imageLoader: CocktailImageDataLoader
    private var task: CocktailImageDataLoaderTask?
    
    var presenter: CocktailImagePresenter<View, Image>?
    
    init(model: CocktailItem, imageLoader: CocktailImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
