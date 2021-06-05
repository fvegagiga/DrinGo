//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class LoadCocktailIngredientsFromRemoteUseCaseTests: XCTestCase {
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            })
        }
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyListJSON = makeItemsJson([])
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let items = makeCocktailIngredients(["Kahlua", "Sambuca", "Blue Curacao", "Baileys irish cream", nil],
                                           measures: ["1/2 oz ", "1 oz ", "3 oz ", "2 oz ", nil])
        
        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items.model), when: {
                let json = makeItemsJson([items.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCocktailIngredientsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCocktailIngredientsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteCocktailIngredientsLoader.Error) -> RemoteCocktailIngredientsLoader.Result {
        return .failure(error)
    }
    
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
    
    private func makeItemsJson(_ items: [[String: Any?]]) -> Data {
        let json = ["drinks": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteCocktailIngredientsLoader, toCompleteWith expectedResult: RemoteCocktailIngredientsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            
            case let (.failure(receivedError as RemoteCocktailIngredientsLoader.Error), .failure(expectedError as RemoteCocktailIngredientsLoader.Error)):
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
