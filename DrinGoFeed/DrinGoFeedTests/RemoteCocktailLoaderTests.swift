//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest

class RemoteCocktailLoader {
    
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

class RemoteCocktailLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteCocktailLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteCocktailLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
