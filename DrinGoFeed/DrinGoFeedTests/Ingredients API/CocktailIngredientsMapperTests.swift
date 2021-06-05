//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class CocktailIngredientsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJson([])
        let samples = [199, 150, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try CocktailIngredientsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        let samples = [200, 201, 250, 280, 299]

        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try CocktailIngredientsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_maps_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJson([])
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            let result = try CocktailIngredientsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: code))
            
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let items = makeCocktailIngredients(["Kahlua", "Sambuca", "Blue Curacao", "Baileys irish cream", nil],
                                           measures: ["1/2 oz ", "1 oz ", "3 oz ", "2 oz ", nil])
        
        let samples = [200, 201, 250, 280, 299]
        let json = makeItemsJson([items.json])

        try samples.forEach { code in
            let result = try CocktailIngredientsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            
            XCTAssertEqual(result, items.model)
        }
    }
    
    // MARK: - Helpers
    
    private func makeCocktailIngredients(_ ingredients: [String?], measures: [String?]) -> (model: [CocktailIngredient], json: [String: Any?]) {
        
        let items: [CocktailIngredient] = zip(ingredients, measures).compactMap {
            guard let name = $0.0 else { return nil }
            return CocktailIngredient(name: name, measure: $0.1 ?? "")
        }
        
        let json: [String: Any?] = [
            "strIngredient1": ingredients[0],
            "strIngredient2": ingredients[1],
            "strIngredient3": ingredients[2],
            "strIngredient4": ingredients[3],
            "strIngredient5": ingredients[4],
            "strMeasure1": measures[0],
            "strMeasure2": measures[1],
            "strMeasure3": measures[2],
            "strMeasure4": measures[3],
            "strMeasure5": measures[4]
        ]
        
        return (items, json)
    }
}
