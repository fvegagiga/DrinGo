//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteCocktailLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}
