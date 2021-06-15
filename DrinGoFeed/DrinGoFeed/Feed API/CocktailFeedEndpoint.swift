//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public enum CocktailFeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/popular.php")
        }
    }
}
