//
//  BusinessCell.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {
  static let identifier = "BusinessCell"
  var business: Yelp.Business! {
    didSet {
      debugPrint(business.imageUrl.url)

      nameLabel.text = business.name
      thumbnailImageView.setImageWithURL(business.imageUrl.url)
      distanceLabel.text = String(format: "%0.2f mi", arguments: [business.distanceInMiles])
      ratingImageView.setImageWithURL(business.ratingImageUrl.url)
      let countNoun = business.reviewCount == 1 ? "review" : "reviews"
      reviewsCount.text = "\(business.reviewCount) \(countNoun)"
    }
  }

  // MARK: - Outlets

  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var ratingImageView: UIImageView!
  @IBOutlet weak var reviewsCount: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
