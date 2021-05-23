//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

protocol FeedImageView {
    func display(_ model: CocktailImageViewModel)
}

struct CocktailImageViewModel {
    let title: String
    let description: String
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
}

private final class CocktailImagePresenter {
    let view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    
    func didStartLoadingImageData(for model: CocktailItem) {
        view.display(CocktailImageViewModel(title: model.name, description: model.description, image: nil, isLoading: true, shouldRetry: false))
    }
}

class CocktailImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let cocktail = uniqueCocktail()
        
        sut.didStartLoadingImageData(for: cocktail)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.title, cocktail.name)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: CocktailImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = CocktailImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return(sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        
        var messages = [CocktailImageViewModel]()
        
        func display(_ model: CocktailImageViewModel) {
            messages.append(model)
        }
    }
}
