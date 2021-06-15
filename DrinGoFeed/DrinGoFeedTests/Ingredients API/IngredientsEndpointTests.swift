//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class IngredientsEndpointTests: XCTestCase {

    func test_imageComments_endpointURL() {
        let cocktailID = 0
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = IngredientsEndopoint.get(cocktailID).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/lookup.php?i=0")!
        
        XCTAssertEqual(received, expected)
    }

}
