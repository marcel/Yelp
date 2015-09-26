//
//  Category.swift
//  Yelp
//
//  Created by Marcel Molina on 9/22/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension Yelp {
  struct Category {
    typealias Alias = String

    // MARK: - Properties

    let title: String
    let alias: Alias
    let supportedCountries: Set<CountryCode>
    let parents: Set<Alias>

    // MARK: - Initializers

    init(title: String, alias: String, supportedCountries: Set<String>, parents: Set<Alias>) {
      self.title              = title
      self.alias              = alias
      self.supportedCountries = supportedCountries
      self.parents            = parents
    }

    init(dictionary: NSDictionary) {
      let payload = Payload(dictionary: dictionary)

      self.init(
        title: payload.title,
        alias: payload.alias,
        supportedCountries: payload.supportedCountries,
        parents: payload.parents
      )
    }

    private static func loadFromFileNamed(name: String) -> [Category] {
      let filePath     = NSBundle.mainBundle().pathForResource(name, ofType: "json")!
      let data         = NSData(contentsOfFile: filePath)!
      let dictionaries = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as! [NSDictionary]

      return dictionaries.map { Category(dictionary: $0) }
    }

    // MARK: - Payload

    private struct Payload {
      let dictionary: NSDictionary

      enum Key: String {
        case Alias              = "alias"
        case Title              = "title"
        case SupportedCountries = "country_whitelist"
        case Parents            = "parents"
      }

      var alias: String {
        return dictionary[Key.Alias.rawValue] as! String
      }

      var title: String {
        return dictionary[Key.Title.rawValue] as! String
      }

      var supportedCountries: Set<CountryCode> {
        let codes = dictionary[Key.SupportedCountries.rawValue] as? [CountryCode]

        return codes.map { Set($0) } ?? Set<CountryCode>()
      }

      var parents: Set<Alias> {
        let parents = dictionary[Key.Parents.rawValue] as? [Alias]

        return parents.map { Set($0) } ?? Set<Alias>()
      }
    }

    // MARK: - Indexes

    static let all         = Category.loadFromFileNamed("categories")
    static let allByAlias  = Category.indexByAlias(all)
    static let allTopLevel = all.filter { $0.parents.isEmpty }
    static let allByParent = Category.indexByParent(all)

    // MARK: - Index Lookups

    static func byAlias(alias: Alias) -> Category? {
      return allByAlias[alias]
    }

    static func withParent(parent: Alias) -> [Category] {
      return allByParent[parent] ?? []
    }

    private static func indexByAlias(categories: [Category]) -> [Alias: Category] {
      var lookUpIndex = [Alias: Category]()

      categories.forEach { category in
        lookUpIndex[category.alias] = category
      }

      return lookUpIndex
    }

    private static func indexByParent(categories: [Category]) -> [Alias: [Category]] {
      var lookupIndex = [Alias: [Category]]()

      categories.forEach { category in
        category.parents.forEach { parent in
          if let _ = lookupIndex[parent] {
            lookupIndex[parent]!.append(category)
          } else {
            lookupIndex[parent] = [category]
          }
        }
      }

      return lookupIndex
    }
  }
}