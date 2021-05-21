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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "CocktailImageCell")!
    }
}
