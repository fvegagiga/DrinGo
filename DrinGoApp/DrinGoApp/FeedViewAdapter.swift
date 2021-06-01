//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed
import DrinGoFeediOS

final class FeedViewAdapter: FeedView {
    private weak var controller: CocktailFeedViewController?
    private let imageLoader: CocktailImageDataLoader
    
    init(controller: CocktailFeedViewController, imageLoader: CocktailImageDataLoader) {
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
