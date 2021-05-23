//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest

final class CocktailFeedPresenter {
    init(view: Any) {
        
    }
}

class CocktailFeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CocktailFeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = CocktailFeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    
    private class ViewSpy {
        let messages = [Any]()
    }
}
