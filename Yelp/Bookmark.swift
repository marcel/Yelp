//
//  Bookmark.swift
//  Yelp
//
//  Created by Marcel Molina on 9/28/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import RealmSwift

class Bookmark: Object {
  dynamic var businessId: Yelp.Id = "<undefined>"
  dynamic var createdAt: NSTimeInterval = -1

  override static func primaryKey() -> String? {
    return "businessId"
  }

  static func create(
    businessId: Yelp.Id,
    createdAt: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
  ) -> Bookmark {
    return Bookmark(value: ["businessId": businessId, "createdAt": createdAt])
  }
}
