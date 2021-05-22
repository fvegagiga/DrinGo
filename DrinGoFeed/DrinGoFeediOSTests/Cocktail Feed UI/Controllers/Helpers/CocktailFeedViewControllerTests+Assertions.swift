//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import XCTest
import DrinGoFeed
import DrinGoFeediOS

extension CocktailFeedViewControllerTests {
    
    func assertThat(_ sut: CocktailFeedViewController, isRendering feed: [CocktailItem], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: CocktailFeedViewController, hasViewConfiguredFor image: CocktailItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.coktailFeedView(at: index)
        
        guard let cell = view as? CocktailFeedCell else {
            return XCTFail("Expected \(CocktailFeedCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, image.name, "Expected title text to be \(String(describing: image.name)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
    }
    
}
