//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public protocol CocktailImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

final public class CocktailFeedViewController: UITableViewController {
    private var loader: CocktailLoader?
    private var feedLoader: CocktailLoader?
    private var imageLoader: CocktailImageDataLoader?

    private var tableModel = [CocktailItem]()

    public convenience init(feedLoader: CocktailLoader, imageLoader: CocktailImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
        
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = CocktailFeedCell()
        cell.titleLabel.text = cellModel.name
        cell.descriptionLabel.text = cellModel.description
        imageLoader?.loadImageData(from: cellModel.imageURL)
        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        imageLoader?.cancelImageDataLoad(from: cellModel.imageURL)
    }
}
