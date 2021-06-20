//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public enum IngredientsEndopoint {
    case getIngredients(Int)
    case getImage(String)
    
    public func url(baseURL: URL) -> URL {
        
        switch self {
        case let .getIngredients(id):
            var urlComponents = URLComponents(string: baseURL.absoluteString)!
            urlComponents.queryItems = [URLQueryItem(name: "i", value: "\(id)")]
            
            return urlComponents.url!.appendingPathComponent("/lookup.php")
            
        case let .getImage(name):
            return baseURL.appendingPathComponent("\(name)-Medium.png")
        }
    }
}
