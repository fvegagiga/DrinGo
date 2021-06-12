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
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<CocktailFeedCellController>>(loader: { [imageLoader] in
                imageLoader(model.imageURL)
            })
            
            let view = CocktailFeedCellController(
                viewModel: CocktailImagePresenter<CocktailFeedCellController, UIImage>.map(model),
                delegate: adapter)
            
            adapter.presenter = LoadResoucePresenter(resourceView: WeakRefVirtualProxy(view),
                                                     loadingView: WeakRefVirtualProxy(view),
                                                     errorView: WeakRefVirtualProxy(view),
                                                     mapper: { data in
                                                        guard let image = UIImage.init(data: data) else {
                                                            throw InvalidImageData()
                                                        }
                                                        return image
                                                     })
            return view
        })
    }
}

private struct InvalidImageData: Error {}
