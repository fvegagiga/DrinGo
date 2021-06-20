//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import UIKit
import Combine
import DrinGoApp
import DrinGoFeed
import DrinGoFeediOS

class IngredientsUIIntegrationTests: XCTestCase {

    func test_ingredientsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title?.contains(ingredientsTitle), true)
    }
    
    func test_loadIngredientsActions_requestIngredientsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadIngredientsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadIngredientsCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadIngredientsCallCount, 1, "Expected no request until previous completes")

        loader.completeIngredientsLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadIngredientsCallCount, 2, "Expected another loading request once user initiates a reload")
        
        loader.completeIngredientsLoading(at: 1)
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
    
    func test_loadIngredientsCompletion_rendersSuccessfullyLoadedIngredients() {
        let ingredient0 = makeIngredient(id: 0, name: "an ingredient", measure: "a measure")
        let ingredient1 = makeIngredient(id: 1, name: "another ingredient", measure: "another measure")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [CocktailIngredient]())

        loader.completeIngredientsLoading(with: [ingredient0], at: 0)
        assertThat(sut, isRendering: [ingredient0])

        sut.simulateUserInitiatedReload()
        loader.completeIngredientsLoading(with: [ingredient0, ingredient1], at: 1)
        assertThat(sut, isRendering: [ingredient0, ingredient1])
    }
    
    func test_loadIngredientsCompletion_rendersSuccessfullyLoadedEmptyIngredientsAfterNonEmptyIngredients() {
        let ingredient = makeIngredient()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeIngredientsLoading(with: [ingredient], at: 0)
        assertThat(sut, isRendering: [ingredient])

        sut.simulateUserInitiatedReload()
        loader.completeIngredientsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [CocktailIngredient]())
    }


    func test_loadIngredientCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let ingredient = makeIngredient()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeIngredientsLoading(with: [ingredient], at: 0)
        assertThat(sut, isRendering: [ingredient])
        
        sut.simulateUserInitiatedReload()
        loader.completeIngredientsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [ingredient])
    }
    
    func test_loadIngredientsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeIngredientsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadIngredientsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeIngredientsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeIngredientsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_deinit_cancelsRunningRequests() {
        var cancelCallCount = 0
        let loader = LoaderSpy()
        var sut: ListViewController?
        
        autoreleasepool {
            sut = IngredientsUIComposer.ingredientsComposedWith(ingredientsLoader: {
                PassthroughSubject<[CocktailIngredient], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            },
            imageLoader: loader.loadImageDataPublisher,
            name: "any",
            imageBaseURL: anyURL())
            sut?.loadViewIfNeeded()
        }
        
        XCTAssertEqual(cancelCallCount, 0)
        
        sut = nil
        
        XCTAssertEqual(cancelCallCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = IngredientsUIComposer.ingredientsComposedWith(
            ingredientsLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            name: "any",
            imageBaseURL: anyURL())
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeIngredient(id: Int = 0, name: String = "any ingredient", measure: String = "any measure") -> CocktailIngredient {
        return CocktailIngredient(name: name, measure: measure)
    }
}
