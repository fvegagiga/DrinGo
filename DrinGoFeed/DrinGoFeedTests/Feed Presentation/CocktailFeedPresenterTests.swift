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
        let view = ViewSpy()

        _ = CocktailFeedPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers

    private class ViewSpy {
        let messages = [Any]()
    }
    
}
