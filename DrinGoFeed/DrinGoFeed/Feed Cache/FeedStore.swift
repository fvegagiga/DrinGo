//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [CocktailItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
