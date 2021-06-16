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
    
    private lazy var baseURL = URL(string: "https://www.thecocktaildb.com/api/json/v2/9973533")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: CocktailUIComposer.feedComposedWith(
            feedLoader: makeRemoteCocktailLoaderWithLocalFallback,
            imageLoader: makeLocalImageDataLoaderWithRemoteFallback,
            selection: showIngredients))

    private var customImageCachePath: String {
        "DrinGo/images/"
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func createCachesDirectoryIfNeeded() {
        let customCachePath = cachesDirectory().appendingPathComponent("DrinGo/images/").path
        try? FileManager.default.createDirectory(atPath: customCachePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func getCacheDirectoryFilePath(for remoteUrl: URL) -> URL {
        let fileName = remoteUrl.lastPathComponent
        createCachesDirectoryIfNeeded()
        
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
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localCocktailLoader.validateCache { _ in }
    }
    
    private func showIngredients(for cocktail: CocktailItem) {
        let url = IngredientsEndopoint.get(cocktail.id).url(baseURL: baseURL)
        let ingredients = IngredientsUIComposer.ingredientsComposedWith(ingredientsLoader: makeRemoteIngredientsLoader(url: url))
        navigationController.pushViewController(ingredients, animated: true)
    }
    
    private func makeRemoteIngredientsLoader(url: URL) -> () -> AnyPublisher<[CocktailIngredient], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(CocktailIngredientsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteCocktailLoaderWithLocalFallback() -> AnyPublisher<[CocktailItem], Error> {
        let url = CocktailFeedEndpoint.get.url(baseURL: baseURL)
        
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
