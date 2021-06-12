//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class IngredientsPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(IngredientsPresenter.title, localized("INGREDIENTS_VIEW_TITLE"))
    }
    
    func test_map_createViewModel() {
        let ingredients = [
            CocktailIngredient(name: "a name", measure: "a measure"),
            CocktailIngredient(name: "another name", measure: "another measure")
        ]
        
        let viewModel = IngredientsPresenter.map(ingredients)
        
        XCTAssertEqual(viewModel.ingredients, [
                        IngredientViewModel(ingredient: "a name", measure: "a measure"),
                        IngredientViewModel(ingredient: "another name", measure: "another measure")])
    }
    
    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Ingredients"
        let bundle = Bundle(for: IngredientsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
