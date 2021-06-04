//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import Combine
import DrinGoFeed
import DrinGoFeediOS

final class CocktailImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: CocktailItem
    private let imageLoader: (URL) -> CocktailImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: CocktailImagePresenter<View, Image>?
    
    init(model: CocktailItem, imageLoader: @escaping (URL) -> CocktailImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        
        cancellable = imageLoader(model.imageURL).sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
            
        }, receiveValue: { [weak self] data in
            self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
