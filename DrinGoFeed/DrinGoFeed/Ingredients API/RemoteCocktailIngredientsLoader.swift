// Copyright @ 2021 Fernando Vega. All rights reserved.

import Foundation

public typealias RemoteCocktailIngredientsLoader = RemoteLoader<[CocktailIngredient]>

public extension RemoteCocktailIngredientsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: CocktailIngredientsMapper.map)
    }
}
