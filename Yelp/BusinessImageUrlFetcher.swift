//
//  BusinessImageFetcher.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation
import Alamofire

class BusinessImageUrlFetcher {
  typealias ImageResults = [NSURL]
  typealias Cache = Dictionary<Yelp.Id, [NSURL]>

  static let sharedInstance = BusinessImageUrlFetcher()

  private var cache: Cache

  static private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36"
  private let headers = ["User-Agent": BusinessImageUrlFetcher.userAgent]
  private let searchUrl = NSURL(string: "https://www.google.com/search")!
  private let startingPointMarker = "id=\"rg_s\""
  private let endingPointMarker   = "id=\"isr_cld\""

  init(cache: Cache = Cache()) {
    self.cache = cache
  }

  func fetchImageUrlsForBusiness(business: Yelp.Business, completion: ImageResults -> ()) {
    if let urls = cache[business.id] {
      completion(urls)
    } else {
      Alamofire.request(
        .GET,
        searchUrl,
        parameters: ["tbm": "isch", "q": queryTermsForBusiness(business)],
        headers: headers
      ).responseString(completionHandler: { (request, response, result) in
        let urls = self.extractLinksFromString(result.value! as String)
        let validOnes = self.foo(urls)
        debugPrint(validOnes)
        self.cache[business.id] = validOnes
        completion(validOnes)
      })
    }
  }

  func extractLinksFromString(string: String) -> [NSURL] {
    let linkDetector = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
    let startIndex = indexOfString(startingPointMarker, inString: string)
    let stopIndex  = indexOfString(endingPointMarker, inString: string)
    let range = NSMakeRange(startIndex, stopIndex - startIndex)

    let matches = linkDetector.matchesInString(string, options: [], range: range)

    return matches.flatMap { $0.URL }
  }

  func foo(urls: [NSURL]) -> [NSURL] {
    let firstComponents = urls.flatMap { NSURLComponents(string: $0.absoluteString)?.queryItems?.first }
    let withImgUrlParam = firstComponents.filter { $0.name == "imgurl" }
    return withImgUrlParam.flatMap { $0.value }.map { Yelp.SecureURL(string: $0).url }
  }

  func indexOfString(subString: String, inString string: String) -> Int {
    let rangeOfSubstring = string.rangeOfString(subString)!
    // So far this is definitely the most beffudling interface in Swift
    return string.startIndex.distanceTo(rangeOfSubstring.startIndex) + 0
  }

  func queryTermsForBusiness(business: Yelp.Business) -> String {
    return "\(business.name)+\(business.location.city)"
  }
}