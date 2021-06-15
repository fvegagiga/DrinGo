//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CocktailFeedEndpointTests: XCTestCase {

    func test_cocktailFeed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = CocktailFeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/popular.php")!
        
        XCTAssertEqual(received, expected)
    }

}
