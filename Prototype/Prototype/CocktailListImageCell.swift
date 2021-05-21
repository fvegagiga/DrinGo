//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import UIKit

final class CocktailImageCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cocktailImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cocktailImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cocktailImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        cocktailImageView.image = image
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: [],
            animations: {
                self.cocktailImageView.alpha = 1
            })
    }

}
