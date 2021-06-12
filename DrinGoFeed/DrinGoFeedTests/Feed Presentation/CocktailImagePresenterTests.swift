//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CocktailImagePresenterTests: XCTestCase {

    func test_map_createsViewModel() {
        let cocktail = uniqueCocktail()
        
        let viewModel = CocktailImagePresenter.map(cocktail)
        
        XCTAssertEqual(viewModel.title, cocktail.name)
        XCTAssertEqual(viewModel.description, cocktail.description)
    }
}
