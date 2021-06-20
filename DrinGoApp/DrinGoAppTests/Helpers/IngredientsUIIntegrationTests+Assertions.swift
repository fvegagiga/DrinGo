//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed
import DrinGoFeediOS

extension IngredientsUIIntegrationTests {
    
    func assertThat(_ sut: ListViewController, isRendering ingredients: [CocktailIngredient], file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        XCTAssertEqual(sut.numberOfRenderedIngredients(), ingredients.count, "ingredients count", file: file, line: line)
        
        ingredients.enumerated().forEach { index, ingredient in
            XCTAssertEqual(sut.ingredientName(at: index), ingredient.name, "ingredient name at \(index)", file: file, line: line)
            XCTAssertEqual(sut.ingredientMeasure(at: index), ingredient.measure, "ingredient name at \(index)", file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor ingredient: CocktailIngredient, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.ingredientView(at: index)
        
        guard let cell = view else {
            return XCTFail("Expected \(IngredientCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.nameLabel.text, ingredient.name, "Expected title text to be \(String(describing: ingredient.name)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.measureLabel.text, ingredient.measure, "Expected description text to be \(String(describing: ingredient.measure)) for image view at index (\(index)", file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
         RunLoop.current.run(until: Date())
     }
}
