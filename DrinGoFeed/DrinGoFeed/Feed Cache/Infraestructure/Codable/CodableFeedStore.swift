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
        
        init(_ cocktail: LocalCocktailItem) {
            self.id = cocktail.id
            self.name = cocktail.name
            self.description = cocktail.description
            self.imageURL = cocktail.imageURL
        }
        
        var local: LocalCocktailItem {
            LocalCocktailItem(id: id, name: name, description: description, imageURL: imageURL)
        }
    }
    
    let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.some(CachedFeed(feed: cache.localCocktails, timestamp: cache.timestamp))))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ cocktails: [LocalCocktailItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: cocktails.map(CodableCocktailItem.init), timestamp: timestamp)
                let encoded = try! encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(.success(()))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
