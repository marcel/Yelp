//
//  File.swift
//  Yelp
//
//  Created by Marcel Molina on 9/22/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

extension Yelp {
  struct SecureURL {
    let url: NSURL

    init(string: String) {
      self.url = SecureURL.httpsVersionOfURL(string)
    }

    private static func httpsVersionOfURL(string: String) -> NSURL {
      let httpsVersion = string.stringByReplacingOccurrencesOfString(
        "http:",
        withString: "https:",
        options: NSStringCompareOptions.LiteralSearch,
        range: nil
      )
      return NSURL(string: httpsVersion)!
    }
  }
}