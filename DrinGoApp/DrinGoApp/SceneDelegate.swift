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
    private lazy var imageBaseURL = URL(string: "https://www.thecocktaildb.com/images/ingredients")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: CocktailUIComposer.feedComposedWith(
            feedLoader: makeRemoteCocktailLoaderWithLocalFallback,
            imageLoader: makeLocalImageDataLoaderWithRemoteFallback,
            selection: showIngredients))

    private var customImageCachePath: String { "DrinGo/images/"}
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func createCachesDirectoryIfNeeded() throws {
        let customCachePath = cachesDirectory().appendingPathComponent(customImageCachePath).path
        try FileManager.default.createDirectory(atPath: customCachePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func getCacheDirectoryFilePath(for remoteUrl: URL) -> URL {
        do {
            try createCachesDirectoryIfNeeded()
        } catch {
            assertionFailure("Failed to create cache directory with error: \(error.localizedDescription)")
        }
        
        let fileName = remoteUrl.lastPathComponent
        return cachesDirectory()
            .appendingPathComponent(customImageCachePath)
            .appendingPathComponent(fileName)
    }
    
    // Mark: - SceneDelegate
    
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
    
    // MARK: - Cocktail Loader
    
    private func makeRemoteCocktailLoaderWithLocalFallback() -> AnyPublisher<[CocktailItem], Error> {
        return makeRemoteCocktailFeedLoader()
            .caching(to: localCocktailLoader)
            .fallback(to: localCocktailLoader.loadPublisher)
    }
    
    private func makeRemoteCocktailFeedLoader() -> AnyPublisher<[CocktailItem], Error> {
        let url = CocktailFeedEndpoint.get.url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(CocktailItemMapper.map)
            .eraseToAnyPublisher()
    }

    // MARK: - Image Data Loader
    
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
    
    private func makeRemoteImageDataLoader(url: URL) -> CocktailImageDataLoader.Publisher {
        return httpClient
            .getPublisher(url: url)
            .tryMap(ImageDataMapper.map)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Ingredients Loader
    
    private func makeRemoteIngredientsLoader(url: URL) -> () -> AnyPublisher<[CocktailIngredient], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(CocktailIngredientsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Navigation
    
    private func showIngredients(for cocktail: CocktailItem) {
        let url = IngredientsEndopoint.getIngredients(cocktail.id).url(baseURL: baseURL)
        let ingredients = IngredientsUIComposer.ingredientsComposedWith(
            ingredientsLoader: makeRemoteIngredientsLoader(url: url),
            imageLoader: makeRemoteImageDataLoader,
            name: cocktail.name,
            imageBaseURL: imageBaseURL)
        navigationController.pushViewController(ingredients, animated: true)
    }
}
