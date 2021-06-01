//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed
import DrinGoFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        
        let url = URL(string: "https://www.thecocktaildb.com/api/json/v2/9973533/randomselection.php")!
        
        let session = URLSession(configuration: .ephemeral)
        let remoteClient = URLSessionHTTPClient(session: session)
        let remoteCocktailLoader = RemoteCocktailLoader(url: url, client: remoteClient)
        let remoteCocktailImageLoader = RemoteCocktailImageDataLoader(client: remoteClient)
        
        let localStoreURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("cocktail.store")
        
        let localStore = CodableFeedStore(storeURL: localStoreURL)
        let localCocktailLoader = LocalCocktailLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalCocktailImageDataLoader(store: localStore)
        
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
