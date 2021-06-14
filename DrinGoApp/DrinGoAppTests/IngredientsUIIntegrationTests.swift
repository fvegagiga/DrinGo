//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import UIKit
import Combine
import DrinGoApp
import DrinGoFeed
import DrinGoFeediOS

class IngredientsUIIntegrationTests: CocktailFeedUIIntegrationTests {

    func test_ingredientsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, ingredientsTitle)
    }
    
    func test_loadIngredientsActions_requestIngredientsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadIngredientsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadIngredientsCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadIngredientsCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadIngredientsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadingIngredientsIndicator_isVisibleWhileLoadingIngredients() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeIngredientsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeIngredientsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(id: 0, title: "a title", description: "a description")
        let image1 = makeImage(id: 1, title: "another title", description: "another description")
        let image2 = makeImage(id: 2, title: "other title", description: "other description")
        let image3 = makeImage(id: 3, title: "some title", description: "some description")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeIngredientsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeIngredientsLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage(id: 0)
        let image1 = makeImage(id: 1)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeIngredientsLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])

        sut.simulateUserInitiatedReload()
        loader.completeIngredientsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }


    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeIngredientsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeIngredientsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeIngredientsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeIngredientsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeIngredientsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = IngredientsUIComposer.ingredientsComposedWith(ingredientsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(id: Int = 0, title: String = "a title", description: String = "a description", imageURL: URL = URL(string: "http://any-url.com")!) -> CocktailItem {
        return CocktailItem(id: id, name: title, description: description, imageURL: imageURL, ingredients: ["Ing1", "Ingr2"], quantity: ["Qt1", "Qt2"])
    }

    private class LoaderSpy {
        
        private var requests = [PassthroughSubject<[CocktailItem], Error>]()
        
        var loadIngredientsCallCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[CocktailItem], Error> {
            let publisher = PassthroughSubject<[CocktailItem], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeIngredientsLoading(with feed: [CocktailItem] = [], at index: Int = 0) {
            requests[index].send(feed)
        }
        
        func completeIngredientsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
