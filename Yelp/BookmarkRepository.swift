//
//  BookmarkRepository.swift
//  Yelp
//
//  Created by Marcel Molina on 9/25/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation
import RealmSwift

class BookmarkRepository {
  static let sharedInstance = BookmarkRepository()

  typealias ModificationToken = NSTimeInterval

  private let store = try! Realm()

  var lastModification: NSTimeInterval {
    return list().first?.createdAt ?? 0
  }

  func add(business: Yelp.Business) -> ModificationToken {
    let bookmark = Bookmark.create(business.id)
    print("(R): add bookmark with id \(business.id)")
    return updateStore() {
      $0.add(bookmark)
    }
  }

  func remove(business: Yelp.Business) -> ModificationToken {
    print("(R): delete bookmark with id \(business.id)")

    return updateStore {
      $0.delete(Bookmark.create(business.id))
    }
  }

  func toggleState(business: Yelp.Business) -> Bool {
    if isBookmarked(business) {
      remove(business)
      return false
    } else {
      add(business)
      return true
    }
  }

  func isBookmarked(business: Yelp.Business) -> Bool {
    return store.objectForPrimaryKey(Bookmark.self, key: business.id) != nil
  }

  private func updateStore(update: Realm -> ()) -> ModificationToken {
    store.write {
      update(self.store)
    }

    return NSDate.timeIntervalSinceReferenceDate()
  }

  func list() -> Results<Bookmark> {
    return store.objects(Bookmark).sorted("createdAt", ascending: false)
  }
}