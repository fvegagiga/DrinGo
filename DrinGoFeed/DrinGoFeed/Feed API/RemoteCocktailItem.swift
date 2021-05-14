//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

struct RemoteCocktailItem: Decodable {
    let idDrink: String
    let strDrink: String
    let strInstructions: String
    let strDrinkThumb: String
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
}
