//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Alexandre Gravelle on 2021-02-28.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmFeedStore: FeedStore {
	
	private let configuration: Realm.Configuration
	
	private struct Cache {
		let feed: [LocalFeedImage]
		let timestamp: Date
		
		var local: RealmCache {
			let realmCache = RealmCache()
			realmCache.feed.append(objectsIn: feed.map { $0.realmFeedImage })
			realmCache.timestamp = timestamp
			return realmCache
		}
	}
	
	public init(configuration: Realm.Configuration) {
		self.configuration = configuration
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			let realm = try self.getRealm()
			try realm.write {
				realm.deleteAll()
				completion(nil)
			}
		} catch {
			completion(error)
		}
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let cache = Cache(feed: feed, timestamp: timestamp)
		
		do {
			let realm = try self.getRealm()
			try realm.write {
				realm.deleteAll()
				realm.add(cache.local)
				completion(nil)
			}
		} catch {
			completion(error)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		do {
			let realm = try self.getRealm()
			guard let realmCache = realm.objects(RealmCache.self).first else {
				return completion(.empty)
			}
			completion(.found(feed: realmCache.local, timestamp: realmCache.timestamp))
		} catch {
			completion(.failure(error))
		}
		
	}
	
	private func getRealm() throws -> Realm {
		return try Realm(configuration: configuration)
	}
}

internal class RealmCache: Object {
	var feed = List<RealmFeedImage>()
	@objc dynamic var timestamp = Date()
	
	var local: [LocalFeedImage] {
		return feed.map { $0.local }
	}
}
