//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest

private final class CocktailImagePresenter {
    init(view: Any) {
        
    }
}

class CocktailImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: CocktailImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = CocktailImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return(sut, view)
    }
    
    private class ViewSpy {
        var messages = [Any]()
    }
}
