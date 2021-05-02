//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest

class RemoteCocktailLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteCocktailLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteCocktailLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
