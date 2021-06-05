//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class LoadCocktailsFromRemoteUseCaseTests: XCTestCase {
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
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
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCocktailLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCocktailLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteCocktailLoader.Error) -> RemoteCocktailLoader.Result {
        return .failure(error)
    }
    
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
    
    private func makeItemsJson(_ items: [[String: Any?]]) -> Data {
        let json = ["drinks": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteCocktailLoader, toCompleteWith expectedResult: RemoteCocktailLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            
            case let (.failure(receivedError as RemoteCocktailLoader.Error), .failure(expectedError as RemoteCocktailLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
