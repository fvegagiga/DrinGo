//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation
import XCTest
import DrinGoFeediOS

extension CocktailFeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "CocktailFeed"
        let bundle = Bundle(for: CocktailFeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
