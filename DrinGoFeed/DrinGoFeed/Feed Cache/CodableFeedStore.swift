//
// Copyright @ 2021 Fernando Vega. All rights reserved.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableCocktailItem]
        let timestamp: Date
        
        var localCocktails: [LocalCocktailItem] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableCocktailItem: Codable {
        private let id: Int
        private let name: String
        private let description: String
        private let imageURL: URL
        private let ingredients: [String]
        private let quantity: [String]
        
        init(_ cocktail: LocalCocktailItem) {
            self.id = cocktail.id
            self.name = cocktail.name
            self.description = cocktail.description
            self.imageURL = cocktail.imageURL
            self.ingredients = cocktail.ingredients
            self.quantity = cocktail.quantity
        }
        
        var local: LocalCocktailItem {
            LocalCocktailItem(id: id, name: name, description: description, imageURL: imageURL, ingredients: ingredients, quantity: quantity)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localCocktails, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ cocktails: [LocalCocktailItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: cocktails.map(CodableCocktailItem.init), timestamp: timestamp)
                let encoded = try! encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
                
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
