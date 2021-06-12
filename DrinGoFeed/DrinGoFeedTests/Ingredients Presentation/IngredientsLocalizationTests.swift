//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class IngredientsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Ingredients"
        let bundle = Bundle(for: IngredientsPresenter.self)
        
        assertLocalizedKeyAndValuesExists(in: bundle, table)
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
