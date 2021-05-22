//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

struct CocktailImageViewModel<Image> {
    let title: String
    let description: String
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}
