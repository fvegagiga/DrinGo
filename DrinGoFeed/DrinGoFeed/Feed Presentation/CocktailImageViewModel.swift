//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public struct CocktailImageViewModel<Image> {
    public let title: String
    public let description: String
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
}
