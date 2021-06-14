//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeediOS

extension ListViewController {
    override public func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
        
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var errorMessage: String? {
        return errorView.message
    }
}

// MARK: - Ingredients View Controller

extension ListViewController {
    func numberOfRenderedIngredients() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: ingredientsSection)
    }
    
    private var ingredientsSection: Int {
        return 0
    }
    
    func ingredientName(at row: Int) -> String? {
        ingredientView(at: row)?.nameLabel.text
    }
    
    func ingredientMeasure(at row: Int) -> String? {
        ingredientView(at: row)?.measureLabel.text
    }
    
    private func ingredientView(at row: Int) -> IngredientCell? {
        guard numberOfRenderedIngredients() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: ingredientsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? IngredientCell
    }
}

// MARK: - Cocktail Feed View Controller

extension ListViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> CocktailFeedCell? {
        return coktailFeedView(at: index) as? CocktailFeedCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> CocktailFeedCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func renderedCocktailImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func coktailFeedView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    private var feedImagesSection: Int {
        return 0
    }
}
