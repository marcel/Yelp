//
//  BookmarkRepository.swift
//  Yelp
//
//  Created by Marcel Molina on 9/25/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

struct Bookmark {
  let businessId: Yelp.Id
  let createdAt: NSDate

  private var createdAtString: String {
    return String(Int(createdAt.timeIntervalSince1970))
  }

  var encoded: [String] {
    return [businessId, createdAtString]
  }

  init(businessId: Yelp.Id, createdAt: NSDate) {
    self.businessId = businessId
    self.createdAt  = createdAt
  }

  init(business: Yelp.Business) {
    self.init(businessId: business.id, createdAt: NSDate())
  }

  static func decode(parts: [String]) -> Bookmark? {
    if parts.count == 2 {
      let businessId = parts[0] as Yelp.Id
      let createdAt  = NSDate(timeIntervalSince1970: Double(parts[1])!)

      return Bookmark(businessId: businessId, createdAt: createdAt)
    } else {
      return .None
    }
  }
}

class BookmarkRepository {
  static let sharedInstance = BookmarkRepository()

  typealias Index = NSMutableDictionary // [Yelp.Id: Bookmark]
  static private let emptyIndex: Index = NSMutableDictionary()

  enum Key: String {
    case Index = "com.andbutso.yelp.bookmarks.index"
  }

  init() {
    self.index = BookmarkRepository.fetchIndex()
  }

  private var index: Index

  func add(business: Yelp.Business) {
    index.setObject(Bookmark(business: business).encoded, forKey: business.id)
    updateStore()
  }

  func remove(business: Yelp.Business) {
    index.removeObjectForKey(business.id)
    updateStore()
  }

  func isBookmarked(business: Yelp.Business) -> Bool {
    return index.objectForKey(business.id) != nil
  }

  func list() -> [Bookmark] {
    if let coarsed = index.allValues as? [[String]] {
      return coarsed.flatMap {
        Bookmark.decode($0)
      }.sort { (lhs, rhs) in
        lhs.createdAt.timeIntervalSince1970 > rhs.createdAt.timeIntervalSince1970
      }
    } else {
      return []
    }
  }

  private func updateStore() {
    let archivedIndex = NSKeyedArchiver.archivedDataWithRootObject(index)
    BookmarkRepository.store.setObject(archivedIndex, forKey: Key.Index.rawValue)
  }

  private var archivedIndex: NSData {
    return NSKeyedArchiver.archivedDataWithRootObject(index)
  }

  private static var store: NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  private static func fetchIndex() -> Index {
    if let archivedData = store.objectForKey(Key.Index.rawValue) as? NSData {
      if let unarchived = NSKeyedUnarchiver.unarchiveObjectWithData(archivedData) as? NSDictionary {
        return BookmarkRepository.dictionaryToIndex(unarchived)
      } else {
        return BookmarkRepository.emptyIndex
      }
    } else {
      return BookmarkRepository.emptyIndex
    }
  }

  static private func dictionaryToIndex(dictionary: NSDictionary) -> Index {
    let index = Index()

    for (_, value) in dictionary {
      if let bookmark = Bookmark.decode(value as! [String]) {
        print("* Restoring bookmark: \(bookmark)")
        index.setObject(bookmark.encoded, forKey: bookmark.businessId)
      } else {
        print("- Could not restore: \(value)")
      }
    }

    return index
  }
}