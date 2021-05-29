//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

class RemoteCocktailImageDataLoader {
    init(client: Any) {
        
    }
}

class RemoteCocktailImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCocktailImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCocktailImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy {
        var requestedURLs = [URL]()
    }
}
