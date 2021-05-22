//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

final class CocktailImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: CocktailImageDataLoaderTask?
    private let model: CocktailItem
    private let imageLoader: CocktailImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    init(model: CocktailItem, imageLoader: CocktailImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    var title: String {
        return model.name
    }
    
    var description: String {
        return model.description
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: CocktailImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
