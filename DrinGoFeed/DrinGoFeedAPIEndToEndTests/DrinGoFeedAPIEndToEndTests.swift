//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class DrinGoFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETCocktailResult_matchesFixedTestAccountData() {
        
        switch getCocktailResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 6, "Expected 6 items in the test account, got \(items.count) cocktails")
            XCTAssertEqual(items[0], expectedItem(at: 0))
            XCTAssertEqual(items[1], expectedItem(at: 1))
            XCTAssertEqual(items[2], expectedItem(at: 2))
            XCTAssertEqual(items[3], expectedItem(at: 3))
            XCTAssertEqual(items[4], expectedItem(at: 4))
            XCTAssertEqual(items[5], expectedItem(at: 5))

        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getCocktailResult(file: StaticString = #filePath, line: UInt = #line) -> RemoteCocktailLoader.Result? {
        let testServerURL = URL(string: "https://www.thecocktaildb.com/api/json/v2/9973533/search.php?s=margarita")!
        let client = URLSessionHTTPClient()
        let loader = RemoteCocktailLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: CocktailLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> CocktailItem {
        return CocktailItem(id: id(at: index),
                            name: name(at: index),
                            description: description(at: index),
                            imageURL: imageURL(at: index),
                            ingredients: ingredients(at: index),
                            quantity: quantity(at: index))
    }
    
    private func id(at index: Int) -> Int {
        let id = [
            "11007",
            "11118",
            "17216",
            "16158",
            "12322",
            "178332"
        ][index]
        return Int(id)!
    }
    
    private func name(at index: Int) -> String {
        return [
            "Margarita",
            "Blue Margarita",
            "Tommy's Margarita",
            "Whitecap Margarita",
            "Strawberry Margarita",
            "Smashed Watermelon Margarita"
        ][index]
    }
    
    private func description(at index: Int) -> String {
        return [
            "Rub the rim of the glass with the lime slice to make the salt stick to it. Take care to moisten only the outer rim and sprinkle the salt on it. The salt should present to the lips of the imbiber and never mix into the cocktail. Shake the other ingredients with ice, then carefully pour into the glass.",
            "Rub rim of cocktail glass with lime juice. Dip rim in coarse salt. Shake tequila, blue curacao, and lime juice with ice, strain into the salt-rimmed glass, and serve.",
            "Shake and strain into a chilled cocktail glass.",
            "Place all ingredients in a blender and blend until smooth. This makes one drink.",
            "Rub rim of cocktail glass with lemon juice and dip rim in salt. Shake schnapps, tequila, triple sec, lemon juice, and strawberries with ice, strain into the salt-rimmed glass, and serve.",
            "In a mason jar muddle the watermelon and 5 mint leaves together into a puree and strain. Next add the grapefruit juice, juice of half a lime and the tequila as well as some ice. Put a lid on the jar and shake. Pour into a glass and add more ice. Garnish with fresh mint and a small slice of watermelon."
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: [
            "https://www.thecocktaildb.com/images/media/drink/5noda61589575158.jpg",
            "https://www.thecocktaildb.com/images/media/drink/bry4qh1582751040.jpg",
            "https://www.thecocktaildb.com/images/media/drink/loezxn1504373874.jpg",
            "https://www.thecocktaildb.com/images/media/drink/srpxxp1441209622.jpg",
            "https://www.thecocktaildb.com/images/media/drink/tqyrpw1439905311.jpg",
            "https://www.thecocktaildb.com/images/media/drink/dztcv51598717861.jpg"
        ][index])!
    }
    
    private func ingredients(at index: Int) -> [String] {
        return [
            ["Tequila", "Triple sec", "Lime juice", "Salt"],
            ["Tequila", "Blue Curacao", "Lime juice", "Salt"],
            ["Tequila", "Lime Juice", "Agave syrup"],
            ["Ice", "Tequila", "Cream of coconut", "Lime juice"],
            ["Strawberry schnapps", "Tequila", "Triple sec", "Lemon juice", "Strawberries"],
            ["Watermelon", "Mint", "Grapefruit Juice", "Lime", "Tequila"]
        ][index]
    }
    
    private func quantity(at index: Int) -> [String] {
        return [
            ["1 1/2 oz ", "1/2 oz ", "1 oz "],
            ["1 1/2 oz ", "1 oz ", "1 oz ", "Coarse "],
            ["4.5 cl", "1.5 cl", "2 spoons"],
            ["1 cup ", "2 oz ", "1/4 cup ", "3 tblsp fresh "],
            ["1/2 oz ", "1 oz ", "1/2 oz ", "1 oz ", "1 oz "],
            ["1/2 cup", "5", "1/3 Cup", "Juice of 1/2", "1 shot"]
        ][index]
    }
}
