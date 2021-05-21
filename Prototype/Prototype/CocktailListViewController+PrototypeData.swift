//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

extension CocktailImageViewModel {
    static var prototypeFeed: [ CocktailImageViewModel] {
        return [
            CocktailImageViewModel(title: "Mojito", imageName: "image-1.jpg", description: "Muddle mint leaves with sugar and lime juice. Add a splash of soda water and fill the glass with cracked ice. Pour the rum and top with soda water. Garnish and serve with straw."),
            CocktailImageViewModel(title: "Old Fashioned", imageName: "image-2", description: "Place sugar cube in old fashioned glass and saturate with bitters, add a dash of plain water. Muddle until dissolved.\r\nFill the glass with ice cubes and add whiskey.\r\n\r\nGarnish with orange twist, and a cocktail cherry."),
            CocktailImageViewModel(title: "Long Island Tea", imageName: "image-3", description: "Combine all ingredients (except cola) and pour over ice in a highball glass. Add the splash of cola for color. Decorate with a slice of lemon and serve."),
            CocktailImageViewModel(title: "Negroni", imageName: "image-4", description: "Stir into glass over ice, garnish and serve."),
            CocktailImageViewModel(title: "Whiskey Sour", imageName: "image-5", description: "Shake with ice. Strain into chilled glass, garnish and serve. If served 'On the rocks', strain ingredients into old-fashioned glass filled with ice."),
            CocktailImageViewModel(title: "Dry Martini", imageName: "image-6", description: "Straight: Pour all ingredients into mixing glass with ice cubes. Stir well. Strain in chilled martini cocktail glass. Squeeze oil from lemon peel onto the drink, or garnish with olive."),
            CocktailImageViewModel(title: "Daiquiri", imageName: "image-7", description: "Pour all ingredients into shaker with ice cubes. Shake well. Strain in chilled cocktail glass.")
        ]
    }
}
