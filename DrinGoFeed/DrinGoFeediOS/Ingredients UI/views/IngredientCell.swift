//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit

public final class IngredientCell: UITableViewCell {
    @IBOutlet private(set) public var nameLabel: UILabel!
    @IBOutlet private(set) public var measureLabel: UILabel!
    @IBOutlet private(set) public var ingredientImageContainer: UIView!
    @IBOutlet private(set) public var ingredientImageView: UIImageView!
    @IBOutlet private(set) public var errorImageView: UIImageView!
}
