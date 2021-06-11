//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CocktailFeedPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(CocktailFeedPresenter.title, localized("COCKTAIL_LIST_VIEW_TITLE"))
    }
    
    func test_map_createViewModel() {
        let feed = uniqueCocktails().models
        
        let viewModel = CocktailFeedPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed)
    }
    
    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "CocktailFeed"
        let bundle = Bundle(for: CocktailFeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
