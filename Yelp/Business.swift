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
    private struct Payload {
      let dictionary: NSDictionary

      enum Key: String {
        case Id             = "id"
        case Name           = "name"
        case ImageUrl       = "image_url"
        case Location       = "location"
        case Categories     = "categories"
        case Distance       = "distance"
        case RatingImageUrl = "rating_img_url_large"
        case Rating         = "rating"
        case ReviewCount    = "review_count"
        case IsClosed       = "is_closed"
      }

      var id: Id {
        return dictionary[Key.Id.rawValue] as! String
      }

      var name: String {
        return dictionary[Key.Name.rawValue] as! String
      }

      var imageUrl: SecureURL? {
        return urlFromKey(Key.ImageUrl)
      }

      var location: Location? {
        let locationDict = dictionary[Key.Location.rawValue] as? NSDictionary

        return locationDict.flatMap { Location(dictionary: $0) }
      }

      var categories: [Category] {
        if let pairs = dictionary[Key.Categories.rawValue] as? [[String]] {
          return pairs.flatMap { pair in Category.byAlias(pair[1]) }
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

      var isClosed: Bool {
        return dictionary[Key.IsClosed.rawValue] as! Int == 1
      }

      private func urlFromKey(key: Key) -> SecureURL? {
        let urlString = dictionary[key.rawValue] as? String

        return urlString.map { SecureURL(string: $0) }
      }
    }

    // MARK: - Properties

    let id: Id
    let name: String
    let location: Location
    let thumbnailUrl: SecureURL?
    let fullSizeImageUrl: SecureURL?
    let ratingImageUrl: SecureURL
    let distanceInMiles: Double?
    let reviewCount: Int
    let categories: [Category]
    let isClosed: Bool

    private let payload: Payload

    // MARK: - Initializers

    // TODO Perhaps make this a failable initializer if any of the expected
    // attributes came back nil and then it can just be flatMapped out of the results
    private init?(payload: Payload) {
      self.payload = payload

      self.id               = payload.id
      self.name             = payload.name
      self.thumbnailUrl     = payload.imageUrl
      self.ratingImageUrl   = payload.ratingImageUrl!
      self.distanceInMiles  = payload.distanceInMiles
      self.reviewCount      = payload.reviewCount!
      self.categories       = payload.categories
      self.isClosed         = payload.isClosed
      self.fullSizeImageUrl = payload.imageUrl.map {
        Business.changeFileInUrl($0, toFileName: "o.jpg")
      }

      if let location = payload.location {
        self.location = location
      } else {
        self.location = Location.undefined
        return nil
      }
    }

    convenience init?(dictionary: NSDictionary) {
      self.init(payload: Payload(dictionary: dictionary))
    }

    static private func changeFileInUrl(url: SecureURL, toFileName: String) -> SecureURL {
      let path = url.url.URLByDeletingLastPathComponent!
      return SecureURL(string: "\(path.absoluteString)\(toFileName)")
    }

    var formatter: Formatter {
      return Formatter(business: self)
    }

    struct Formatter {
      let business: Yelp.Business
      let separator = ", "

      func nameWithResultNumber(number: Int) -> String {
        return "\(number). \(business.name)"
      }

      var distanceInMiles: String? {
        return business.distanceInMiles.map { distance in
          String(format: "%0.2f mi", arguments: [distance])
        }
      }

      var reviewCount: String {
        let count = business.reviewCount
        let countNoun = count == 1 ? "review" : "reviews"
        return "\(count) \(countNoun)"
      }

      var categories: String {
        return business.categories.map {
          $0.title
          }.joinWithSeparator(separator)
      }

      var address: String {
        let location          = business.location
        let addresses         = location.addresses
        let neighborhoods     = location.neighborhoods
        let addressComponents = [addresses.first, neighborhoods.first]

        return addressComponents.flatMap { $0 }.joinWithSeparator(separator)
      }
    }
  }
}