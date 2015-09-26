//
//  Review.swift
//  Yelp
//
//  Created by Marcel Molina on 9/23/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension Yelp {
  struct Review {
    let id: Id
    let rating: Int
    let ratingImageUrl: SecureURL
    let excerpt: String
    let timeCreated: NSDate
    let user: User

    private init(payload: Payload) {
      self.id             = payload.id
      self.rating         = payload.rating
      self.ratingImageUrl = payload.ratingImageUrl
      self.excerpt        = payload.excerpt
      self.timeCreated    = payload.timeCreated
      self.user           = payload.user
    }

    init(dictionary: NSDictionary) {
      self.init(payload: Payload(dictionary: dictionary))
    }

    private struct Payload {
      let dictionary: NSDictionary

      enum Key: String {
        case Id             = "id"
        case Rating         = "rating"
        case RatingImageUrl = "rating_image_large_url"
        case Excerpt        = "excerpt"
        case TimeCreated    = "time_created"
        case User           = "user"
      }

      var id: String {
        return dictionary[Key.Id.rawValue] as! String
      }

      var rating: Int {
        return dictionary[Key.Rating.rawValue] as! Int
      }

      var ratingImageUrl: SecureURL {
        return SecureURL(string: dictionary[Key.RatingImageUrl.rawValue] as! String)
      }

      var excerpt: String {
        return dictionary[Key.Excerpt.rawValue] as! String
      }

      var timeCreated: NSDate {
        let secondsSinceEpoch = dictionary[Key.TimeCreated.rawValue] as! Double

        return NSDate(timeIntervalSince1970: secondsSinceEpoch)
      }

      var user: User {
        return User(dictionary: dictionary[Key.User.rawValue] as! NSDictionary)
      }
    }
  }
}