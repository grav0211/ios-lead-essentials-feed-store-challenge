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
	
	public init(configuration: Realm.Configuration) {
		self.configuration = configuration
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		do {
			let realm = try self.getRealm()
			try realm.write {
				realm.deleteAll()
			}
			completion(nil)
		} catch {
			completion(error)
		}
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let cache = RealmCache()
		cache.feed = feed.toRealmList()
		cache.timestamp = timestamp
		
		do {
			let realm = try self.getRealm()
			try realm.write {
				realm.deleteAll()
				realm.add(cache)
			}
			completion(nil)
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

internal class RealmFeedImage: Object {
	@objc dynamic var id = ""
	@objc dynamic var desc: String?
	@objc dynamic var location: String?
	@objc dynamic var url = ""
	
	var local: LocalFeedImage {
		return LocalFeedImage(id: UUID(uuidString: id)!, description: desc, location: location, url: URL(string: url)!)
	}
}

private extension Array where Element == LocalFeedImage {

	func toRealmList() -> List<RealmFeedImage> {
		let list = List<RealmFeedImage> ()
		forEach {
			let realmImage = RealmFeedImage()
			realmImage.id = $0.id.uuidString
			realmImage.desc = $0.description
			realmImage.location = $0.location
			realmImage.url = $0.url.absoluteString
			list.append(realmImage)
		}
		return list
	}
}
