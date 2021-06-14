//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import Combine
import DrinGoFeed
import DrinGoFeediOS

public final class IngredientsUIComposer {
    private init() {}
    
    private typealias IngredientsPresentationAdapter = LoadResourcePresentationAdapter<[CocktailIngredient], IngredientsViewAdapter>
    
    public static func ingredientsComposedWith(
        ingredientsLoader: @escaping () -> AnyPublisher<[CocktailIngredient], Error>
    ) -> ListViewController {
        let presentationAdapter = IngredientsPresentationAdapter(loader: ingredientsLoader)
        
        let ingredientsController = makeIngredientsViewController(title: IngredientsPresenter.title)
        ingredientsController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResoucePresenter(
            resourceView: IngredientsViewAdapter(controller: ingredientsController),
            loadingView: WeakRefVirtualProxy(ingredientsController),
            errorView: WeakRefVirtualProxy(ingredientsController),
            mapper: IngredientsPresenter.map)
        return ingredientsController
    }

    private static func makeIngredientsViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Ingredients", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

final class IngredientsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: IngredientsViewModel) {
        controller?.display(viewModel.ingredients.map { viewModel in
            CellController(id: viewModel, IngredientCellController(model: viewModel))
        })
    }
}
