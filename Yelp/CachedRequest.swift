//
//  CachedRequest.swift
//  Yelp
//
//  Created by Marcel Molina on 9/27/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation

class CachedRequest: NSURLRequest {
  static let cachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
  static let timeoutInterval: NSTimeInterval = 60

  init(url: NSURL) {
    super.init(
      URL: url,
      cachePolicy: CachedRequest.cachePolicy,
      timeoutInterval: CachedRequest.timeoutInterval
    )
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}