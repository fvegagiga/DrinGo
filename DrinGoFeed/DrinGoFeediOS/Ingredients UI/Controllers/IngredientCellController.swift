//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit
import DrinGoFeed

public class IngredientCellController: CellController {
    private let model: IngredientViewModel
    
    public init (model: IngredientViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: IngredientCell = tableView.dequeueReusableCell()
        cell.nameLabel.text = model.ingredient
        cell.measureLabel.text = model.measure
        return cell
    }
    
    public func preload() {
        
    }
    
    public func cancelLoad() {
        
    }
    
    
}
