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
  
  var imageURL: NSURL! {
    didSet {
      imageView.setImageWithURLRequest(
        CachedRequest(url: imageURL),
        placeholderImage: ImageGridCell.placeholder,
        success: { request, response, image in
          UIView.transitionWithView(self.imageView,
            duration: 1,
            options: [.TransitionCrossDissolve, .AllowUserInteraction],
            animations: { self.imageView.image = image },
            completion: nil
          )

        },
        failure: { request, response, error in
          print("Failed to load: \(self.imageURL.absoluteString)")
        }
      )
    }
  }

  @IBOutlet weak var imageView: UIImageView!
}