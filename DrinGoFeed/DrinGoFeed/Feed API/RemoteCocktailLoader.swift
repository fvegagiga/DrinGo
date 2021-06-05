//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public typealias RemoteCocktailLoader = RemoteLoader<[CocktailItem]>

public extension RemoteCocktailLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: CocktailItemMapper.map)
    }
}
