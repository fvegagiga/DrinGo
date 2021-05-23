//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: CocktailImageViewModel<Image>)
}

struct CocktailImageViewModel<Image> {
    let title: String
    let description: String
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

private final class CocktailImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: CocktailItem) {
        view.display(CocktailImageViewModel(title: model.name,
                                            description: model.description,
                                            image: nil,
                                            isLoading: true,
                                            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: CocktailItem) {
        let image = imageTransformer(data)
        view.display(CocktailImageViewModel(title: model.name,
                                            description: model.description,
                                            image: image,
                                            isLoading: false,
                                            shouldRetry: image == nil))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: CocktailItem) {
        view.display(CocktailImageViewModel(title: model.name,
                                            description: model.description,
                                            image: nil,
                                            isLoading: false,
                                            shouldRetry: true))
    }
}

class CocktailImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let cocktail = uniqueCocktail()
        
        sut.didStartLoadingImageData(for: cocktail)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.title, cocktail.name)
        XCTAssertEqual(message?.description, cocktail.description)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let cocktail = uniqueCocktail()
        
        sut.didFinishLoadingImageData(with: Data(), for: cocktail)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.title, cocktail.name)
        XCTAssertEqual(message?.description, cocktail.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let cocktail = uniqueCocktail()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: Data(), for: cocktail)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.title, cocktail.name)
        XCTAssertEqual(message?.description, cocktail.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let cocktail = uniqueCocktail()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: cocktail)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.title, cocktail.name)
        XCTAssertEqual(message?.description, cocktail.description)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }

    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #filePath, line: UInt = #line) -> (sut: CocktailImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = CocktailImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return(sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: FeedImageView {
        
        var messages = [CocktailImageViewModel<AnyImage>]()
        
        func display(_ model: CocktailImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
