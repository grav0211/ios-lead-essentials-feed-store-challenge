//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public struct LocalFeedImage: Equatable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
	
	public init(id: UUID, description: String?, location: String?, url: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.url = url
	}
	
	var realmFeedImage: RealmFeedImage {
		let realmFeedImage = RealmFeedImage()
		realmFeedImage.id = id.uuidString
		realmFeedImage.desc = description
		realmFeedImage.location = location
		realmFeedImage.url = url.absoluteString
		return realmFeedImage
	}
}

public class RealmFeedImage: Object {
	@objc dynamic var id = ""
	@objc dynamic var desc: String?
	@objc dynamic var location: String?
	@objc dynamic var url = ""
	
	var local: LocalFeedImage {
		return LocalFeedImage(id: UUID(uuidString: id)!, description: desc, location: location, url: URL(string: url)!)
	}
}
