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
  
  var imageURL: NSURL! {
    didSet {
      imageView.setImageWithURL(imageURL)
    }
  }

  @IBOutlet weak var imageView: UIImageView!
}