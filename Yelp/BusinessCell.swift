//
//  BusinessCell.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

@IBDesignable
class BusinessCell: UITableViewCell {
  static let identifier = "BusinessCell"
  static let defaultThumbnailImage = UIImage(named: "business_90_square.png")

  var resultNumber: Int = 0

  var result: (Int, Yelp.Business) {
    get {
      return (resultNumber, business)
    }

    set {
      self.resultNumber = newValue.0
      self.business     = newValue.1
    }
  }

  var business: Yelp.Business! {
    didSet {
      assert(resultNumber != 0, "Result number must be set")

      setThumbnailOrDefault() 
      ratingImageView.setImageWithURL(business.ratingImageUrl.url)

      let formatting = Formatting(business: business)

      nameLabel.text       = formatting.nameWithResultNumber(resultNumber)
      distanceLabel.text   = formatting.distanceInMiles
      reviewsCount.text    = formatting.reviewCount
      categoriesLabel.text = formatting.categories
      addressLabel.text    = formatting.address
    }
  }

  @IBInspectable
  var thumbnailCornerRadius: CGFloat = 3.0 {
    didSet {
      updateThumbnailCornerRadius()
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
    updateThumbnailCornerRadius()
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  private func updateThumbnailCornerRadius() {
    thumbnailImageView?.layer.cornerRadius = thumbnailCornerRadius
  }

  private func setThumbnailOrDefault() {
    if let thumbnailUrl = business.imageUrl?.url {
      thumbnailImageView.setImageWithURL(thumbnailUrl)
    } else {
      thumbnailImageView.image = BusinessCell.defaultThumbnailImage
    }
  }

  struct Formatting {
    let business: Yelp.Business
    let separator = ", "

    func nameWithResultNumber(number: Int) -> String {
      return "\(number). \(business.name)"
    }

    var distanceInMiles: String {
      let distance = business.distanceInMiles
      return String(format: "%0.2f mi", arguments: [distance])
    }

    var reviewCount: String {
      let count = business.reviewCount
      let countNoun = count == 1 ? "review" : "reviews"
      return "\(count) \(countNoun)"
    }

    var categories: String {
      return business.categories.map {
        $0.name
      }.joinWithSeparator(separator)
    }

    var address: String {
      let addresses         = business.addresses
      let neighborhoods     = business.neighborhoods
      let addressComponents = [addresses.first, neighborhoods.first]

      return addressComponents.flatMap { $0 }.joinWithSeparator(separator)
    }
  }
}
