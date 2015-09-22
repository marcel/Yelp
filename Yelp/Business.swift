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

    struct Category {
      let name: String
      let alias: String
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
        case Neighborhoods  = "location.neighborhoods"
        case Categories     = "categories"
        case Distance       = "distance"
        case RatingImageUrl = "rating_img_url_large"
        case Rating         = "rating"
        case ReviewCount    = "review_count"
      }

      var name: String {
        return dictionary[Key.Name.rawValue] as! String
      }

      var imageUrl: SecureURL? {
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

      var addresses: [String] {
        return dictionary.valueForKeyPath(
          Key.Addresses.rawValue
        ) as? [String] ?? []
      }

      var neighborhoods: [String] {
        return dictionary.valueForKeyPath(
          Key.Neighborhoods.rawValue
        ) as? [String] ?? []
      }

      var categories: [Category] {
        if let pairs = dictionary[Key.Categories.rawValue] as? [[String]] {
          return pairs.flatMap { pair in Category(name: pair[0], alias: pair[1]) }
        } else {
          return []
        }
      }

      var distanceInMeters: Int? {
        return dictionary[Key.Distance.rawValue] as? Int
      }

      var distanceInMiles: Double? {
        let milesPerMeter = 0.000621371

        return distanceInMeters.map { Double($0) * milesPerMeter }
      }

      var ratingImageUrl: SecureURL? {
        return urlFromKey(Key.RatingImageUrl)
      }

      var rating: Int? {
        return dictionary[Key.Rating.rawValue] as? Int
      }

      var reviewCount: Int? {
        return dictionary[Key.ReviewCount.rawValue] as? Int
      }

      private func urlFromKey(key: Key) -> SecureURL? {
        let urlString = dictionary[key.rawValue] as? String

        return urlString.map { SecureURL(string: $0) }
      }
    }

    // MARK: - Properties

    let name: String
    let addresses: [String]
    let neighborhoods: [String]
    let imageUrl: SecureURL?
    let ratingImageUrl: SecureURL
    let distanceInMiles: Double
    let reviewCount: Int
    let categories: [Category]
    // TODO ETC

    private let payload: Payload

    // MARK: - Initializers

    // TODO Perhaps make this a failable initializer if any of the expected
    // attributes came back nil and then it can just be flatMapped out of the results
    init(payload: Payload) {
      self.payload = payload

      self.name            = payload.name
      self.addresses       = payload.addresses
      self.neighborhoods   = payload.neighborhoods
      self.imageUrl        = payload.imageUrl
      self.ratingImageUrl  = payload.ratingImageUrl!
      self.distanceInMiles = payload.distanceInMiles!
      self.reviewCount     = payload.reviewCount!
      self.categories      = payload.categories
    }

    convenience init(dictionary: NSDictionary) {
      self.init(payload: Payload(dictionary: dictionary))
    }
  }
}