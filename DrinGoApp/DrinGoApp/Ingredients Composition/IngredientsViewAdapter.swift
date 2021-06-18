//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed
import DrinGoFeediOS

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
