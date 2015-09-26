//
//  User.swift
//  Yelp
//
//  Created by Marcel Molina on 9/23/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension Yelp {
  struct User {
    let id: Id
    let imageUrl: SecureURL
    let name: String

    private init(payload: Payload) {
      self.id       = payload.id
      self.imageUrl = payload.imageUrl
      self.name     = payload.name
    }

    init(dictionary: NSDictionary) {
      self.init(payload: Payload(dictionary: dictionary))
    }

    private struct Payload {
      let dictionary: NSDictionary

      enum Key: String {
        case Id       = "id"
        case ImageUrl = "image_url"
        case Name     = "name"
      }

      var id: String {
        return dictionary[Key.Id.rawValue] as! String
      }

      var imageUrl: SecureURL {
        return SecureURL(string: dictionary[Key.ImageUrl.rawValue] as! String)
      }

      var name: String {
        return dictionary[Key.Name.rawValue] as! String
      }
    }
  }
}