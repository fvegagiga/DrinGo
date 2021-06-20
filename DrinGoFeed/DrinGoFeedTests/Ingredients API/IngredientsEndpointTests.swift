//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class IngredientsEndpointTests: XCTestCase {

    func test_ingredients_endpointURL() {
        let cocktailID = 0
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = IngredientsEndopoint.getIngredients(cocktailID).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/lookup.php?i=0")!
        
        XCTAssertEqual(received, expected)
    }

    func test_ingredientsImage_endpointURL() {
        let ingredientName = "any ingredient name"
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = IngredientsEndopoint.getImage(ingredientName).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/any%20ingredient%20name-Medium.png")!
                
        XCTAssertEqual(received, expected)
    }
}
