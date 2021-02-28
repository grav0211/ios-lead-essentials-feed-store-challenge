//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Alexandre Gravelle on 2021-02-28.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RealmFeedStore: FeedStore {
	
	public init() {}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		completion(nil)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		completion(nil)
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
}
