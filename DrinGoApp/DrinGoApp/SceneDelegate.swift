//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import Combine
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

    private lazy var localCocktailLoader: LocalCocktailLoader = {
        LocalCocktailLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & CocktailImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {

        let cocktailViewController = CocktailUIComposer.feedComposedWith(
            feedLoader: makeRemoteCocktailLoaderWithLocalFallback,
            imageLoader: makeLocalImageDataLoaderWithRemoteFallback)
        
        window?.rootViewController = UINavigationController(rootViewController: cocktailViewController)
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localCocktailLoader.validateCache { _ in }
    }
    
    private func makeRemoteCocktailLoaderWithLocalFallback() -> AnyPublisher<[CocktailItem], Error> {
        let url = URL(string: "https://www.thecocktaildb.com/api/json/v2/9973533/randomselection.php")!
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(CocktailItemMapper.map)
            .caching(to: localCocktailLoader)
            .fallback(to: localCocktailLoader.loadPublisher)
    }
    
    private func makeLocalImageDataLoaderWithRemoteFallback(url: URL) -> CocktailImageDataLoader.Publisher {
        let localImageLoader = LocalCocktailImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(ImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
