//
//  Business.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension Yelp {
  class Business {
    struct Coordinate {
      let latitude: Double
      let longitude: Double
    }

    struct Payload {
      let dictionary: NSDictionary

      enum Key: String {
        case Name           = "name"
        case ImageUrl       = "image_url"
        case Location       = "location"
        case Latitude       = "location.coordinate.latitude"
        case Longitude      = "location.coordinate.longitude"
        case Addresses      = "location.address"
        case Neighborhoods  = "neighborhoods"
        case Categories     = "categories"
        case Distance       = "distance"
        case RatingImageUrl = "rating_img_url_large"
        case Rating         = "rating"
        case ReviewCount    = "review_count"
      }

      var name: String {
        return dictionary[Key.Name.rawValue] as! String
      }

      var imageUrl: NSURL? {
        return urlFromKey(Key.ImageUrl)
      }

      var location: NSDictionary? {
        return dictionary[Key.Location.rawValue] as? NSDictionary
      }

      var coordinate: Coordinate? {
        guard let latitude  = dictionary.valueForKeyPath(Key.Latitude.rawValue) as? Double,
              let longitude = dictionary.valueForKeyPath(Key.Longitude.rawValue) as? Double else {
            return nil
        }

        return Coordinate(latitude: latitude, longitude: longitude)
      }

      var addresses: [String]? {
        return dictionary.valueForKeyPath(Key.Addresses.rawValue) as? [String]
      }

      var neighborhoods: [String]? {
        return location.flatMap { $0[Key.Neighborhoods.rawValue] as? [String] }
      }

      var categories: [[String]]? {
        return dictionary[Key.Categories.rawValue] as? [[String]]
      }

      var distanceInMeters: Int? {
        return dictionary[Key.Distance.rawValue] as? Int
      }

      var distanceInMiles: Double? {
        let milesPerMeter = 0.000621371

        return distanceInMeters.map { Double($0) * milesPerMeter }
      }

      var ratingImgUrl: NSURL? {
        return urlFromKey(Key.ImageUrl)
      }

      var rating: Int? {
        return dictionary[Key.Rating.rawValue] as? Int
      }

      var reviewCount: Int? {
        return dictionary[Key.ReviewCount.rawValue] as? Int
      }

      private func urlFromKey(key: Key) -> NSURL? {
        let urlString = dictionary[key.rawValue] as? String

        return urlString.map { NSURL(string: $0)! }
      }
    }

    // MARK: - Properties

    let name: String
//    let address: String
//    let imageUrl: NSURL
    // TODO ETC

    private let payload: Payload

    // MARK: - Initializers

    init(payload: Payload) {
      self.payload = payload

      self.name = payload.name
    }

    convenience init(dictionary: NSDictionary) {
      self.init(payload: Payload(dictionary: dictionary))
    }
  }
}