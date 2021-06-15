//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public enum IngredientsEndopoint {
    case get(Int)
    
    public func url(baseURL: URL) -> URL {
        
        switch self {
        case let .get(id):
            var urlComponents = URLComponents(string: baseURL.absoluteString)!
            urlComponents.queryItems = [URLQueryItem(name: "i", value: "\(id)")]
            
            return urlComponents.url!.appendingPathComponent("/lookup.php")
        }
    }
}
