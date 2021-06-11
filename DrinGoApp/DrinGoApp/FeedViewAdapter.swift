//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed
import DrinGoFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: CocktailFeedViewController?
    private let imageLoader: (URL) -> CocktailImageDataLoader.Publisher

    init(controller: CocktailFeedViewController, imageLoader: @escaping (URL) -> CocktailImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = CocktailImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<CocktailFeedCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = CocktailFeedCellController(delegate: adapter)
            
            adapter.presenter = CocktailImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        })
    }
}
