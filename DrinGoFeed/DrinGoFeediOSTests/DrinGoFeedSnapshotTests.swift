//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeediOS
@testable import DrinGoFeed

class DrinGoFeedSnapshotTests: XCTestCase {

    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())

        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())

        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }

    
    // MARK: - Helpers

    private func makeSUT() -> CocktailFeedViewController {
        let bundle = Bundle(for: CocktailFeedViewController.self)
        let storyboard = UIStoryboard(name: "CocktailFeed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! CocktailFeedViewController
        controller.loadViewIfNeeded()
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

    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private extension CocktailFeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CocktailFeedCellController] = stubs.map { stub in
            let cellController = CocktailFeedCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: CocktailImageViewModel<UIImage>
    weak var controller: CocktailFeedCellController?

    init(title: String, description: String, image: UIImage?) {
        viewModel = CocktailImageViewModel(
            title: title,
            description: description,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
}
