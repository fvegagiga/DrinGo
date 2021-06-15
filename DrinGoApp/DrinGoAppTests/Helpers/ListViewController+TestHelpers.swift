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
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

// MARK: - Ingredients View Controller

extension ListViewController {
    func numberOfRenderedIngredients() -> Int {
        numberOfRows(in: ingredientsSection)
    }
    
    func ingredientName(at row: Int) -> String? {
        ingredientView(at: row)?.nameLabel.text
    }
    
    func ingredientMeasure(at row: Int) -> String? {
        ingredientView(at: row)?.measureLabel.text
    }
    
    private func ingredientView(at row: Int) -> IngredientCell? {
        cell(row: row, section: ingredientsSection) as? IngredientCell
    }
    
    private var ingredientsSection: Int { 0 }
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
    
    func simulateTapOnCocktailItem(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
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
        numberOfRows(in: feedImagesSection)
    }
    
    func coktailFeedView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedImagesSection) as? CocktailFeedCell
    }

    private var feedImagesSection: Int { 0 }
}
