//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

protocol CocktailLoader {
    typealias Result = Swift.Result<[CocktailItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
