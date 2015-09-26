//
//  YelpClient.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import Foundation
import AFNetworking
import BDBOAuth1Manager

extension Yelp {
  class Client {
    static let baseUrl = NSURL(string: "https://api.yelp.com/v2/")!

    // MARK: Typealiases

    typealias RequestManager = BDBOAuth1RequestOperationManager

    struct AuthConfig {
      let consumerKey: String
      let consumerSecret: String
      let token: String
      let tokenSecret: String

      static let defaultConfig = AuthConfig(
        consumerKey: "xKFG7au6ndly1s9smP5Egg",
        consumerSecret: AuthConfig.d("VjZ5dy1ydWNTWUctWEZlM3Q0N0Ixa0ZPRXZv"),
        token: "6MtfEx4qN4wom9IIovm3QgEGY3jSsdng",
        tokenSecret: AuthConfig.d("U2hoaFNvblJGd0JHTmFjaVNOVUNfNDdNZFVJ")
      )

      private static func d(s: String) -> String {
        return NSString(
          data: NSData(
            base64EncodedString: s,
            options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!,
            encoding: NSUTF8StringEncoding
        ) as! String
      }

      func requestManagerForUrl(baseUrl: NSURL) -> BDBOAuth1RequestOperationManager {
        return BDBOAuth1RequestOperationManager(
          baseURL: baseUrl,
          consumerKey: consumerKey,
          consumerSecret: consumerSecret
        )
      }

      func credential() -> BDBOAuth1Credential {
        return BDBOAuth1Credential(token: token, secret: tokenSecret, expiration: nil)
      }
    }

    struct SearchQuery {
      let term: String
      let limit: Int
      let offset: Int
      let sort: SortMode
      let categories: [String]
      let radius: Int
      let onlyDeals: Bool

      struct Default {
        static let term = ""
        static let limit = 20
        static let offset = 0
        static let sort = SortMode.Distance
        static let categories: [String] = []
        static let radius = SearchQuery.milesToRadius(10) // Max allowed is 40,000 (i.e. 25 miles)
        static let onlyDeals = false
      }

      static func milesToRadius(miles: Float) -> Int {
        return Int(miles * 1600)
      }

      init(
        term: String         = Default.term,
        limit: Int           = Default.limit,
        offset: Int          = Default.offset,
        sort: SortMode       = Default.sort,
        categories: [String] = Default.categories,
        radius: Int          = Default.radius,
        onlyDeals: Bool      = Default.onlyDeals
      ) {
        self.term       = term
        self.limit      = limit
        self.offset     = offset
        self.sort       = sort
        self.categories = categories
        self.radius     = radius
        self.onlyDeals  = onlyDeals
      }

      func copy(
        term: String?         = nil,
        limit: Int?           = nil,
        offset: Int?          = nil,
        sort: SortMode?       = nil,
        categories: [String]? = nil,
        radius: Int?          = nil,
        onlyDeals: Bool?      = nil
      ) -> SearchQuery {
        return SearchQuery(
          term:       term       ?? self.term,
          limit:      limit      ?? self.limit,
          offset:     offset     ?? self.offset,
          sort:       sort       ?? self.sort,
          categories: categories ?? self.categories,
          radius:     radius     ?? self.radius,
          onlyDeals:  onlyDeals  ?? self.onlyDeals
        )
      }

      var parameters: [String:String] {
        return [
          "term":            term,
          "limit":           String(limit),
          "offset":          String(offset),
          "sort":            String(sort.rawValue),
          "category_filter": categories.joinWithSeparator(","),
          "radius_filter":   String(radius),
          "deals_filter":    String(onlyDeals)
        ]
      }
    }

    // MARK: Enums

    enum SortMode: Int {
      case BestMatched = 0, Distance, HighestRated
    }

    // MARK: - Properties

    let authConfig: AuthConfig
    private let requestManager: RequestManager
    private let token: BDBOAuth1Credential

    // MARK: - Initializers

    init(_ authConfig: AuthConfig) {
      self.authConfig     = authConfig
      self.requestManager = authConfig.requestManagerForUrl(Client.baseUrl)
      self.token          = authConfig.credential()

      requestManager.requestSerializer.saveAccessToken(token)
    }

    convenience init() {
      self.init(AuthConfig.defaultConfig)
    }

    func synchronizedManager<R>(request: RequestManager -> R) {
      objc_sync_enter(requestManager)
      request(requestManager)
      objc_sync_exit(requestManager)
    }

    // MARK: - Public Interface

    static func requestPathForBusinessById(id: Id) -> String {
      return "business/\(urlEscape(id))"
    }

    static func requestPathForBusiness(business: Business) -> String {
      return requestPathForBusinessById(business.id)
    }

    func reviewsForBusiness(business: Business, completion: ([Review]!, NSError!) -> Void) {
      synchronizedManager({ requestManager in
        requestManager.GET(
          Client.requestPathForBusiness(business),
          parameters: [:],
          success: { operation, response in
            let dictionaries = response["reviews"] as? [NSDictionary]
            if dictionaries != nil {
              debugPrint(dictionaries)

              let reviews = dictionaries!.map { Review(dictionary: $0) }
              completion(reviews, nil)
            }
          }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(nil, error)
        })
      })
    }

    func businessWithId(id: Id, completion: (Business!, NSError!) -> Void, failure: (() -> ())?) {
      synchronizedManager({ requestManager in
        requestManager.GET(
          Client.requestPathForBusinessById(id),
          parameters: [:],
          success: { operation, response in
            if let result = response as? NSDictionary {
              debugPrint(result)
              completion(Business(dictionary: result), nil)
            }
          },failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            failure?()
        })
      })
    }

    // Yelp's API does not provide a multi-get endpoint for businesses so we have to
    // scatter gather which in tern requires some explicit synchronization
    func businessesWithIds(ids: [Id], completion: [Business] -> ()) -> Void {
      let gatheredResults = SynchronizedDictionary<Id, Business>(minimumCapacity: ids.count)

      let dispatchGroup = dispatch_group_create()
      print("businessesWithIds:", ids.joinWithSeparator(","))
      ids.forEach { id in
        dispatch_group_enter(dispatchGroup)
        print("Requesting \(id)")
        self.businessWithId(id, completion: { (business, _) in
            print("Got \(business.id)")
            gatheredResults.updateValue(business, forKey: business.id)
            dispatch_group_leave(dispatchGroup)
          },
          failure: {
            print("Failure for \(id)")
            dispatch_group_leave(dispatchGroup)
          }
        )
      }

      dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), {
        print("Done with group")
        let businesses = ids.flatMap { gatheredResults.dictionary[$0] }
        print("\(businesses.count) out of \(ids.count)")
        completion(businesses)
      })
    }

    func search(term: String, completion: ([Business]!, NSError!) -> Void) {
      return search( completion: completion)
    }

    func search(query: SearchQuery = SearchQuery(), completion: ([Business]!, NSError!) -> Void) {
      // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api

      var parameters = query.parameters
      // TODO Determine current location
      parameters["ll"] = "37.7666691,-122.4333135"

      print(parameters)

      synchronizedManager({ requestManager in
        requestManager.GET(
          "search",
          parameters: parameters,
          success: { (operation, response) in
            if let dictionaries = response["businesses"] as? [NSDictionary] {
              debugPrint(dictionaries)

              let businesses = dictionaries.map { Business(dictionary: $0) }
              completion(businesses, nil)
            }
          }, failure: { (operation, error) in
            completion(nil, error)
        })
      })
    }

    private static func urlEscape(parameter: String) -> String {
      let allowedCharacterSet = NSCharacterSet.URLPathAllowedCharacterSet()
      
      return parameter.stringByAddingPercentEncodingWithAllowedCharacters(
        allowedCharacterSet
      )!
    }
  }
  
}

class SynchronizedDictionary<Key: Hashable,Value> {
  var dictionary: [Key: Value]!

  init(minimumCapacity: Int) {
    self.dictionary = Dictionary<Key,Value>(minimumCapacity: minimumCapacity)
  }

  func updateValue(value: Value, forKey key: Key) -> Value? {
    objc_sync_enter(self)
    let result = dictionary.updateValue(value, forKey: key)
    objc_sync_exit(self)

    return result
  }
}