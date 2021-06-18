//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import DrinGoFeed

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueCocktail(id: Int = 0) -> [CocktailItem] {
    return [CocktailItem(id: id, name: "any", description: "any", imageURL: anyURL())]
}

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
