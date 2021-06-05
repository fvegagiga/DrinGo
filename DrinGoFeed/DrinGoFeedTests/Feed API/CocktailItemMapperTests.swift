//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CocktailItemMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse()  throws {
        let json = makeItemsJson([])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try CocktailItemMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try CocktailItemMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJson([])
        let result = try CocktailItemMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        
        let item1 = makeCocktailItem(id: 0,
                                 name: "any cocktail name",
                                 description: "any cocktail description",
                                 imageURL: URL(string: "https://a-url.com")!,
                                 ingredient1: "Kahlua",
                                 ingredient2: "Sambuca",
                                 ingredient3: "Blue Curacao",
                                 ingredient4: "Baileys irish cream",
                                 ingredient5: nil,
                                 quantity1: "1 oz ",
                                 quantity2: "1 oz ",
                                 quantity3: "1 oz ",
                                 quantity4: "1 oz ",
                                 quantity5: nil)
        
        let item2 = makeCocktailItem(id: 1,
                                 name: "any second cocktail name",
                                 description: "any second cocktail description",
                                 imageURL: URL(string: "https://another-url.com")!,
                                 ingredient1: "Kahlua",
                                 ingredient2: "Sambuca",
                                 ingredient3: nil,
                                 ingredient4: nil,
                                 ingredient5: nil,
                                 quantity1: "1 oz ",
                                 quantity2: "1 oz ",
                                 quantity3: nil,
                                 quantity4: nil,
                                 quantity5: nil)
        
        let json = makeItemsJson([item1.json, item2.json])
        
        let result = try CocktailItemMapper.map(json, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    
    private func makeCocktailItem(id: Int,
                                  name: String,
                                  description: String,
                                  imageURL: URL,
                                  ingredient1: String?,
                                  ingredient2: String?,
                                  ingredient3: String?,
                                  ingredient4: String?,
                                  ingredient5: String?,
                                  quantity1: String?,
                                  quantity2: String?,
                                  quantity3: String?,
                                  quantity4: String?,
                                  quantity5: String?)
    -> (model: CocktailItem, json: [String: Any?]) {
        
        let item = CocktailItem(id: id,
                                name: name,
                                description: description,
                                imageURL: imageURL,
                                ingredients: [ingredient1, ingredient2, ingredient3, ingredient4, ingredient5].compactMap { $0 },
                                quantity: [quantity1, quantity2, quantity3, quantity4, quantity5].compactMap { $0 })
        
        let json: [String: Any?] = [
            "idDrink": String(id),
            "strDrink": name,
            "strInstructions": description,
            "strDrinkThumb": imageURL.absoluteString,
            "strIngredient1": ingredient1,
            "strIngredient2": ingredient2,
            "strIngredient3": ingredient3,
            "strIngredient4": ingredient4,
            "strIngredient5": ingredient5,
            "strMeasure1": quantity1,
            "strMeasure2": quantity2,
            "strMeasure3": quantity3,
            "strMeasure4": quantity4,
            "strMeasure5": quantity5
        ]
        
        return (item, json)
    }
}
