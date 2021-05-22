//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: CocktailImageViewModel<Image>)
}

final class CocktailImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    internal init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: CocktailItem) {
        view.display(CocktailImageViewModel(
                        title: model.name,
                        description: model.description,
                        image: nil,
                        isLoading: true,
                        shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: CocktailItem) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(CocktailImageViewModel(
                        title: model.name,
                        description: model.description,
                        image: image,
                        isLoading: false,
                        shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: CocktailItem) {
        view.display(CocktailImageViewModel(
                        title: model.name,
                        description: model.description,
                        image: nil,
                        isLoading: false,
                        shouldRetry: true))
    }
}
