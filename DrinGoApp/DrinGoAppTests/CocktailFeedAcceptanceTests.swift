//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed
import DrinGoFeediOS
@testable import DrinGoApp

class CocktailFeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedCocktailImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedCocktailImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedCocktailImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedCocktailImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)

        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }

    func tests_onCocktailFeedSelection_displaysIngredients() {
        let ingredients = showIngredientsForFirstCocktail()
        
        XCTAssertEqual(ingredients.numberOfRenderedIngredients(), 4)
    }

    // MARK: - Helpers

    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func showIngredientsForFirstCocktail() -> ListViewController {
        let cocktails = launch(httpClient: .online(response), store: .empty)
        
        cocktails.simulateTapOnCocktailItem(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = cocktails.navigationController
        return nav?.topViewController as! ListViewController
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-1", "/image-2":
            return makeImageData()
            
        case "/api/json/v2/9973533/popular.php":
            return makeCocktailData()
            
        case "/api/json/v2/9973533/lookup.php":
            return makeIngredientsData()
            
        default:
            return Data()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeCocktailData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["drinks": [
            ["idDrink": "0", "strDrink": "drink name", "strInstructions": "drink description", "strDrinkThumb": "https://www.thecocktaildb.com/image-1", "strIngredient1": "ing1", "strMeasure1": "qt1"],
            ["idDrink": "1", "strDrink": "drink name", "strInstructions": "drink description", "strDrinkThumb": "https://www.thecocktaildb.com/image-2", "strIngredient1": "ing1", "strMeasure1": "qt1"]
        ]])
    }
    
    private func makeIngredientsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["drinks": [
            [            "strIngredient1": "ingredients1",
                         "strIngredient2": "ingredients2",
                         "strIngredient3": "ingredients3",
                         "strIngredient4": "ingredients4",
                         "strIngredient5": nil,
                         "strMeasure1": "measure1",
                         "strMeasure2": "measure2",
                         "strMeasure3": "measure3",
                         "strMeasure4": nil,
                         "strMeasure5": nil
            ],
        ]])

    }
}
