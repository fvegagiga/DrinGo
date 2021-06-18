//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public struct CocktailItem: Hashable {
    public let id: Int
    public let name: String
    public let description: String
    public let imageURL: URL
    
    public init(id: Int, name: String, description: String, imageURL: URL) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
    }
}
