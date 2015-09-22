//
//  YelpClient.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

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

    // MARK: - Public Interface

    func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
      return searchWithTerm(term, sort: nil, categories: nil, deals: nil, completion: completion)
    }

    func searchWithTerm(term: String, sort: SortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
      // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api

      // TODO Determine current location
      
      // Default the location to San Francisco
      var parameters: [String : AnyObject] = ["term": term, "ll": "37.7666691,-122.4333135"]

      if sort != nil {
        parameters["sort"] = sort!.rawValue
      }

      if categories != nil && categories!.count > 0 {
        parameters["category_filter"] = (categories!).joinWithSeparator(",")
      }

      if deals != nil {
        parameters["deals_filter"] = deals!
      }

      print(parameters)

      return requestManager.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let dictionaries = response["businesses"] as? [NSDictionary]
        if dictionaries != nil {
          debugPrint(dictionaries)

          let businesses = dictionaries!.map { Business(dictionary: $0) }
          completion(businesses, nil)
        }
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
          completion(nil, error)
      })
    }

  }
}