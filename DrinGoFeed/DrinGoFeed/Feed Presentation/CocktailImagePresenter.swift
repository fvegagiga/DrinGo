//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: CocktailImageViewModel<Image>)
}

public final class CocktailImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: CocktailItem) {
        view.display(CocktailImageViewModel(title: model.name,
                                            description: model.description,
                                            image: nil,
                                            isLoading: true,
                                            shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: CocktailItem) {
        let image = imageTransformer(data)
        view.display(CocktailImageViewModel(title: model.name,
                                            description: model.description,
                                            image: image,
                                            isLoading: false,
                                            shouldRetry: image == nil))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: CocktailItem) {
        view.display(CocktailImageViewModel(title: model.name,
                                            description: model.description,
                                            image: nil,
                                            isLoading: false,
                                            shouldRetry: true))
    }
    
    public static func map(_ cocktail: CocktailItem) -> CocktailImageViewModel<Image> {
        CocktailImageViewModel(title: cocktail.name,
                               description: cocktail.description,
                               image: nil,
                               isLoading: false,
                               shouldRetry: false)
    }
}
