//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed
import DrinGoFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & CocktailImageDataStore = {
        let localStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("cocktail.store")
        return CodableFeedStore(storeURL: localStoreURL)
    }()

    convenience init(httpClient: HTTPClient, store: FeedStore & CocktailImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        
        let url = URL(string: "https://www.thecocktaildb.com/api/json/v2/9973533/randomselection.php")!
        
        let remoteClient = httpClient
        let remoteCocktailLoader = RemoteCocktailLoader(url: url, client: remoteClient)
        let remoteCocktailImageLoader = RemoteCocktailImageDataLoader(client: remoteClient)
        
        let localCocktailLoader = LocalCocktailLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalCocktailImageDataLoader(store: store)
        
        let cocktailViewController = CocktailUIComposer.feedComposedWith(
            feedLoader: CocktailLoaderWithFallbackComposite(
                primary: CocktailLoaderCacheDecorator(
                    decoratee: remoteCocktailLoader,
                    cache: localCocktailLoader),
                fallback: localCocktailLoader),
            imageLoader: CocktailImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: CocktailImageDataLoaderCacheDecorator(
                    decoratee: remoteCocktailImageLoader,
                    cache: localImageLoader)
            ))
        
        window?.rootViewController = UINavigationController(rootViewController: cocktailViewController)
    }
}
