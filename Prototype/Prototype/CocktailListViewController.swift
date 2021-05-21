//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit

struct CocktailImageViewModel {
    let title: String
    let imageName: String
    let description: String
}

final class CocktailListViewController: UITableViewController {
    
    private var cocktails = [CocktailImageViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.cocktails.isEmpty {
                self.cocktails = CocktailImageViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktails.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CocktailImageCell", for: indexPath) as! CocktailImageCell
        let model = cocktails[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension CocktailImageCell {
    func configure(with model: CocktailImageViewModel) {
        titleLabel.text = model.title
        fadeIn(UIImage(named: model.imageName))
        descriptionLabel.text = model.description
    }
}
