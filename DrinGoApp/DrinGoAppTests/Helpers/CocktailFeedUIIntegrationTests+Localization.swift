//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import XCTest
import DrinGoFeed

extension CocktailFeedUIIntegrationTests {

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResoucePresenter<Any, DummyView>.loadError
    }
    
    var cocktailListTitle: String {
        CocktailFeedPresenter.title
    }
    
    var ingredientsTitle: String {
        IngredientsPresenter.title
    }
}
