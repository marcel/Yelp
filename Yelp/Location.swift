//
//  Location.swift
//  Yelp
//
//  Created by Marcel Molina on 9/23/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension Yelp {
  struct Coordinate {
    let latitude: Double
    let longitude: Double
  }
  
  struct Location {
    static let undefined = Location()
    
    private struct Payload {
      let dictionary: NSDictionary

      enum Key: String {
        case Latitude       = "coordinate.latitude"
        case Longitude      = "coordinate.longitude"
        case City           = "city"
        case CountryCode    = "country_code"
        case CrossStreets   = "cross_streets"
        case PostalCode     = "postal_code"
        case StateCode      = "state_code"
        case Addresses      = "address"
        case Neighborhoods  = "neighborhoods"
      }

      var coordinate: Coordinate? {
        guard let latitude  = dictionary.valueForKeyPath(Key.Latitude.rawValue) as? Double,
          let longitude = dictionary.valueForKeyPath(Key.Longitude.rawValue) as? Double else {
            return nil
        }

        return Coordinate(latitude: latitude, longitude: longitude)
      }

      var postalCode: String? {
        return stringFromKey(Key.PostalCode)
      }

      var city: String {
        return stringFromKey(Key.City)!
      }

      var countryCode: String {
        return stringFromKey(Key.CountryCode)!
      }

      var crossStreets: String? {
        return stringFromKey(Key.CrossStreets)
      }

      var stateCode: String {
        return stringFromKey(Key.StateCode)!
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

      private func stringFromKey(key: Key) -> String? {
        return dictionary[key.rawValue] as? String
      }
    }

    let addresses: [String]    // 451 Castro St
    let city: String           // San Francisco
    let stateCode: String      // CA
    let postalCode: String?        // 94114
    let crossStreets: String?  // 18th St & 17th St
    let coordinate: Coordinate
    let countryCode: String    // US
    let neighborhoods: [String]   // Castro

    private init?(payload: Payload) {
      guard let _ = payload.coordinate else {
        return nil
      }

      self.city          = payload.city
      self.stateCode     = payload.stateCode
      self.addresses     = payload.addresses
      self.postalCode    = payload.postalCode
      self.coordinate    = payload.coordinate!
      self.countryCode   = payload.countryCode
      self.crossStreets  = payload.crossStreets
      self.neighborhoods = payload.neighborhoods
    }

    init?(dictionary: NSDictionary) {
      self.init(payload: Payload(dictionary: dictionary))
    }
    
    init(
      addresses: [String]     = [],
      city: String            = "",
      stateCode: String       = "",
      postalCode: String      = "",
      crossStreets: String    = "",
      coordinate: Coordinate  = Coordinate(latitude: 0.0, longitude: 0.0),
      countryCode: String     = "",
      neighborhoods: [String] = []
      ) {
        self.addresses     = addresses
        self.city          = city
        self.stateCode     = stateCode
        self.postalCode    = postalCode
        self.crossStreets  = crossStreets
        self.coordinate    = coordinate
        self.countryCode   = countryCode
        self.neighborhoods = neighborhoods
    }

    var formatter: Location.Formatter {
      return Formatter(location: self)
    }

    struct Formatter {
      let location: Location

      var address: String {
        let components = [
          location.addresses.first,
          location.city,
          location.stateCode
          ].flatMap { $0 }

        let joined = components.joinWithSeparator(", ")

        let postalCode = location.postalCode ?? ""

        return "\(joined) \(postalCode)"
      }

      var crossStreets: String? {
        return location.crossStreets.map { "b/t \($0)" }
      }

      var neighborhood: String? {
        if let neighborhood = location.neighborhoods.first {
          return "in \(neighborhood)"
        } else {
          return nil
        }
      }

      var crossStreetsAndNeighborhood: String {
        switch (crossStreets, neighborhood) {
          case (.Some, .Some):
            return "(\(crossStreets!)) \(neighborhood!)"
          case (.None, .Some):
            return "\(neighborhood!)"
          case (.Some, .None):
            return "(\(crossStreets!))"
          case (.None, .None):
            return ""
        }
      }
    }
  }
}