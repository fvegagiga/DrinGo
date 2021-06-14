//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeediOS
@testable import DrinGoFeed

class IngredientsSnapshotTests: XCTestCase {

    func test_listWithIngredients() {
        let sut = makeSUT()
        
        sut.display(ingredients())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "INGREDIENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "INGREDIENTS_dark")
    }
    
    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Ingredients", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func ingredients() -> [CellController] {
        ingredientsControllers().map { CellController($0) }
    }
    
    private func ingredientsControllers() -> [IngredientCellController] {
        return [
            IngredientCellController(
                model: IngredientViewModel(
                    ingredient: "First ingredient",
                    measure: "1 1/2 oz")),
            IngredientCellController(
                model: IngredientViewModel(
                    ingredient: "Second ingredient with a long name",
                    measure: "1 oz")),
            IngredientCellController(
                model: IngredientViewModel(
                    ingredient: "Third ingredient",
                    measure: ""))
        ]
    }
}
