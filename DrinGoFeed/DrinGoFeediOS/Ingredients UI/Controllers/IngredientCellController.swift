//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public class IngredientCellController: NSObject, CellController {
    private let model: IngredientViewModel
    
    public init (model: IngredientViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IngredientCell = tableView.dequeueReusableCell()
        cell.nameLabel.text = model.ingredient
        cell.measureLabel.text = model.measure
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {}
}
