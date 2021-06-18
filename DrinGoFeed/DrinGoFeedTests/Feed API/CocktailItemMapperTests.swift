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
                                 imageURL: URL(string: "https://a-url.com")!)
        
        let item2 = makeCocktailItem(id: 1,
                                 name: "any second cocktail name",
                                 description: "any second cocktail description",
                                 imageURL: URL(string: "https://another-url.com")!)
        
        let json = makeItemsJson([item1.json, item2.json])
        
        let result = try CocktailItemMapper.map(json, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    
    private func makeCocktailItem(id: Int,
                                  name: String,
                                  description: String,
                                  imageURL: URL)
    -> (model: CocktailItem, json: [String: Any?]) {
        
        let item = CocktailItem(id: id,
                                name: name,
                                description: description,
                                imageURL: imageURL)
        
        let json: [String: Any?] = [
            "idDrink": String(id),
            "strDrink": name,
            "strInstructions": description,
            "strDrinkThumb": imageURL.absoluteString
        ]
        
        return (item, json)
    }
}
