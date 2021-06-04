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
        
        let remoteCocktailImageLoader = RemoteCocktailImageDataLoader(client: httpClient)
        let localImageLoader = LocalCocktailImageDataLoader(store: store)
        
        let cocktailViewController = CocktailUIComposer.feedComposedWith(
            feedLoader: makeRemoteCocktailLoaderWithLocalFallback,
            imageLoader: makeLocalImageDataLoaderWithRemoteFallback)
        
        window?.rootViewController = UINavigationController(rootViewController: cocktailViewController)
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localCocktailLoader.validateCache { _ in }
    }
    
    private func makeRemoteCocktailLoaderWithLocalFallback() -> CocktailLoader.Publisher {
        let url = URL(string: "https://www.thecocktaildb.com/api/json/v2/9973533/randomselection.php")!
        
        let remoteCocktailLoader = RemoteCocktailLoader(url: url, client: httpClient)
        
        return remoteCocktailLoader
            .loadPublisher()
            .caching(to: localCocktailLoader)
            .fallback(to: localCocktailLoader.loadPublisher)
    }
    
    private func makeLocalImageDataLoaderWithRemoteFallback(url: URL) -> CocktailImageDataLoader.Publisher {
        let remoteCocktailImageLoader = RemoteCocktailImageDataLoader(client: httpClient)
        let localImageLoader = LocalCocktailImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                        remoteCocktailImageLoader
                        .loadImageDataPublisher(from: url)
                        .caching(to: localImageLoader, using: url)
            })
    }
}

// MARK: - CocktailImageDataLoader

public extension CocktailImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: CocktailImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: CocktailImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension CocktailImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

// MARK: - CocktailLoader

public extension CocktailLoader {
    typealias Publisher = AnyPublisher<[CocktailItem], Error>
    
    func loadPublisher() -> Publisher {
        return Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [CocktailItem] {
    func caching(to cache: CocktailCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

private extension CocktailCache {
    func saveIgnoringResult(_ feed: [CocktailItem]) {
        save(feed) { _ in }
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.inmediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var inmediateWhenOnMainQueueScheduler: InmediateWhenOnMainQueueScheduler {
        InmediateWhenOnMainQueueScheduler.shared
    }
    
    struct InmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: Self.SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: Self.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }

        func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
