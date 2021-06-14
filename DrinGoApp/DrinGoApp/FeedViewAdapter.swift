//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed
import DrinGoFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> CocktailImageDataLoader.Publisher

    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<CocktailFeedCellController>>
    
    init(controller: ListViewController, imageLoader: @escaping (URL) -> CocktailImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.imageURL)
            })
            
            let view = CocktailFeedCellController(
                viewModel: CocktailImagePresenter.map(model),
                delegate: adapter)
            
            adapter.presenter = LoadResoucePresenter(resourceView: WeakRefVirtualProxy(view),
                                                     loadingView: WeakRefVirtualProxy(view),
                                                     errorView: WeakRefVirtualProxy(view),
                                                     mapper: UIImage.tryMake)
            return CellController(id: model, view)
        })
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}

