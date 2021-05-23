//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public final class CocktailUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: CocktailLoader, imageLoader: CocktailImageDataLoader) -> CocktailFeedViewController {
        let presentationAdapter = CocktailFeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let cocktailFeedController = CocktailFeedViewController.makeWith(delegate: presentationAdapter, title: CocktailFeedPresenter.title)
        
        presentationAdapter.presenter = CocktailFeedPresenter(
            feedView: FeedViewAdapter(
                controller: cocktailFeedController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(cocktailFeedController)
        )

        return cocktailFeedController
    }
}

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: CocktailLoader where T == CocktailLoader {

    func load(completion: @escaping (CocktailLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: CocktailImageDataLoader where T == CocktailImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

private extension CocktailFeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> CocktailFeedViewController {
        let bundle = Bundle(for: CocktailFeedViewController.self)
        let storyboard = UIStoryboard(name: "CocktailFeed", bundle: bundle)
        let cocktailFeedController = storyboard.instantiateInitialViewController() as! CocktailFeedViewController
        cocktailFeedController.delegate = delegate
        cocktailFeedController.title = title
        return cocktailFeedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: CocktailImageViewModel<UIImage>) {
        object?.display(model)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: CocktailFeedViewController?
    private let imageLoader: CocktailImageDataLoader
    
    init(controller: CocktailFeedViewController, imageLoader: CocktailImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = CocktailImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<CocktailFeedCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = CocktailFeedCellController(delegate: adapter)
            
            adapter.presenter = CocktailImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}

private final class CocktailFeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: CocktailLoader
    var presenter: CocktailFeedPresenter?
    
    init(feedLoader: CocktailLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class CocktailImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: CocktailItem
    private let imageLoader: CocktailImageDataLoader
    private var task: CocktailImageDataLoaderTask?
    
    var presenter: CocktailImagePresenter<View, Image>?
    
    init(model: CocktailItem, imageLoader: CocktailImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
