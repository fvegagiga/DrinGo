//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeediOS
@testable import DrinGoFeed

class DrinGoFeedSnapshotTests: XCTestCase {

    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }

    
    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "CocktailFeed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyFeed() -> [CocktailFeedCellController] {
        return []
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(title: "A Cocktail", description: "The first cocktail recipe", image: UIImage.make(withColor: .red)),
            ImageStub(title: "Another Cocktail", description: "The second cocktail recipe with more text to test the multiline description label", image: UIImage.make(withColor: .green))
        ]
    }

    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(title: "A Cocktail", description: "The first cocktail", image: nil),
            ImageStub(title: "Another Cocktail", description: "The second cocktail", image: nil)
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = CocktailFeedCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
            stub.controller = cellController
            return CellController(id: UUID(), cellController)
        }
        
        display(cells)
    }
}

private class ImageStub: ImageCellControllerDelegate {
    let viewModel: CocktailImageViewModel
    let image: UIImage?
    weak var controller: CocktailFeedCellController?

    init(title: String, description: String, image: UIImage?) {
        self.viewModel = CocktailImageViewModel(
            title: title,
            description: description)
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
