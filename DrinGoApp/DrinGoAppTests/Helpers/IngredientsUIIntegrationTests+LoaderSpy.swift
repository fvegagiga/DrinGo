//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import Combine
import DrinGoFeed
import DrinGoFeediOS

extension IngredientsUIIntegrationTests {
    
    class LoaderSpy: CocktailImageDataLoader {
        
        // MARK: - IngredientsLoader
        
        private var requests = [PassthroughSubject<[CocktailIngredient], Error>]()
        
        var loadIngredientsCallCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[CocktailIngredient], Error> {
            let publisher = PassthroughSubject<[CocktailIngredient], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeIngredientsLoading(with ingredients: [CocktailIngredient] = [], at index: Int = 0) {
            requests[index].send(ingredients)
            requests[index].send(completion: .finished)
        }
        
        func completeIngredientsLoadingWithError(at index: Int = 0) {
            requests[index].send(completion: .failure(anyNSError()))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct TaskSpy: CocktailImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (CocktailImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (CocktailImageDataLoader.Result) -> Void) -> CocktailImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].completion(.failure(anyNSError()))
        }
    }
}
