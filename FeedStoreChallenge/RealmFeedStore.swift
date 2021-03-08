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
	
	private var realm: Realm!
	
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
		self.realm = try! Realm(configuration: configuration)
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			try realm.write {
				deleteRealmCacheIfNeeded()
				completion(nil)
			}
		} catch {
			completion(error)
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let cache = Cache(feed: feed, timestamp: timestamp)
		
		do {
			try realm.write {
				deleteRealmCacheIfNeeded()
				realm.add(cache.local)
				completion(nil)
			}
			
			
		} catch {
			completion(error)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		guard let realmCache = realm.objects(RealmCache.self).first else {
			return completion(.empty)
		}
		completion(.found(feed: realmCache.local, timestamp: realmCache.timestamp))
	}
	
	private func deleteRealmCacheIfNeeded() {
		if let realmCache = realm.objects(RealmCache.self).first {
			realm.delete(realmCache)
		}
	}
}

public class RealmCache: Object {
	var feed = List<RealmFeedImage>()
	@objc dynamic var timestamp = Date()
	
	var local: [LocalFeedImage] {
		return feed.map { $0.local }
	}
}
