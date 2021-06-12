//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
@testable import DrinGoFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "CocktailFeed"
        let bundle = Bundle(for: CocktailFeedPresenter.self)

        assertLocalizedKeyAndValuesExists(in: bundle, table)
    }
}
