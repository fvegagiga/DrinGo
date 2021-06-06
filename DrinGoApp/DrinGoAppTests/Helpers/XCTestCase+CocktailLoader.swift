// Copyright @ 2021 Fernando Vega. All rights reserved.

import XCTest
import DrinGoFeed

protocol CocktailLoaderTestCase: XCTestCase {}

extension CocktailLoaderTestCase {
    func expect(_ sut: LocalCocktailLoader, toCompleteWith expectedResult: Swift.Result<[CocktailItem], Error>, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
                
        wait(for: [exp], timeout: 1.0)
    }
}
