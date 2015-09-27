//
//  ImageGridCell.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class ImageGridCell: UICollectionViewCell {
  static let identifier = "ImageGridCell"
  static let placeholder = UIImage(named: "landscape-placeholder.png")
  
  var imageURL: NSURL!

  func setImageUrl(
    url: NSURL,
    completion: (UIImage -> ())? = .None,
    failure: (NSError -> ())? = .None
  ) {
    self.imageURL = url

    imageView.setImageWithURLRequest(
      CachedRequest(url: imageURL),
      placeholderImage: ImageGridCell.placeholder,
      success: { request, response, image in
        completion?(image)
        UIView.transitionWithView(self.imageView,
          duration: 1,
          options: [.TransitionCrossDissolve, .AllowUserInteraction],
          animations: { self.imageView.image = image },
          completion: nil
        )

      },
      failure: { request, response, error in
        failure?(error)
        print("Failed to load: \(self.imageURL.absoluteString)")
      }
    )
  }

  @IBOutlet weak var imageView: UIImageView!
}