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
    
    private let cocktails = CocktailImageViewModel.prototypeFeed
    
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
        cocktailImageView.image = UIImage(named: model.imageName)
        descriptionLabel.text = model.description
    }
}
