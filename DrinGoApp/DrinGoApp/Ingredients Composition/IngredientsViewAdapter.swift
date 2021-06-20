//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed
import DrinGoFeediOS

final class IngredientsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> CocktailImageDataLoader.Publisher
    private let imageBaseURL: URL
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<IngredientCellController>>
    
    init(controller: ListViewController, imageLoader: @escaping (URL) -> CocktailImageDataLoader.Publisher, imageBaseURL: URL) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.imageBaseURL = imageBaseURL
    }
    
    func display(_ viewModel: IngredientsViewModel) {
        let controllers: [CellController] = viewModel.ingredients.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader,  imageBaseURL] in
                let imageURL = IngredientsEndopoint.getImage(model.ingredient)
                return imageLoader(imageURL.url(baseURL: imageBaseURL))
            })
            
            let view = IngredientCellController(
                viewModel: model,
                delegate: adapter)
            
            adapter.presenter = LoadResoucePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            return CellController(id: model, view)
        }
        
        controller?.display(controllers)
    }
}
