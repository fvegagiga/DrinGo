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

    private var customImageCachePath: String {
        "DrinGo/images/"
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func createCachesDirectory() {
        let customCachePath = cachesDirectory().appendingPathComponent("DrinGo/images/").path
        try? FileManager.default.createDirectory(atPath: customCachePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func getCacheDirectoryFilePath(for remoteUrl: URL) -> URL {
        let fileName = remoteUrl.lastPathComponent
        createCachesDirectory()
        
        
        return cachesDirectory()
            .appendingPathComponent("DrinGo/images/")
            .appendingPathComponent("\(fileName)")
    }
    
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
        let localFilePath = getCacheDirectoryFilePath(for: url)
        
        return localImageLoader
            .loadImageDataPublisher(from: localFilePath)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(ImageDataMapper.map)
                    .caching(to: localImageLoader, using: localFilePath)
            })
    }
}
