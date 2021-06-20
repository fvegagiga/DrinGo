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
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "INGREDIENTS_light_extraExtraExtraLarge")
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
    
    private func ingredients() -> [ImageStub] {
        return [
            ImageStub(ingredient: "First ingredient",
                      measure: "1 1/2 oz",
                      image: UIImage.make(withColor: .red)),
            ImageStub(ingredient: "Second ingredient with a long name",
                      measure: "1 oz",
                      image: UIImage.make(withColor: .green)),
            ImageStub(ingredient: "Third ingredient",
                      measure: "",
                      image: nil)
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = IngredientCellController(viewModel: stub.viewModel, delegate: stub)
            stub.controller = cellController
            return CellController(id: UUID(), cellController)
        }
        
        display(cells)
    }
}

private class ImageStub: ImageCellControllerDelegate {
    let viewModel: IngredientViewModel
    let image: UIImage?
    weak var controller: IngredientCellController?

    init(ingredient: String, measure: String, image: UIImage?) {
        self.viewModel = IngredientViewModel(
            ingredient: ingredient,
            measure: measure)
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
        
        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }
    
    func didCancelImageRequest() {}
}
