//
//  BusinessCell.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

struct BookmarkRowAction {
  static func tableView(
    tableView: UITableView,
    bookmarkActionForRowAtIndexPath indexPath: NSIndexPath,
    business: Yelp.Business
  ) -> UITableViewRowAction {
    let bookmarkRepository = BookmarkRepository.sharedInstance
    let actionTitle = bookmarkRepository.isBookmarked(business) ? "Remove Bookmark" : "Add Bookmark"

    let bookmarkAction = UITableViewRowAction(
      style: UITableViewRowActionStyle.Normal,
      title: actionTitle,
      handler: { (action, indexPath) in
        print("Handler run for row \(indexPath.row)")

        bookmarkRepository.toggleState(business)

        tableView.setEditing(false, animated: true)
        tableView.reloadRowsAtIndexPaths(
          [indexPath],
          withRowAnimation: UITableViewRowAnimation.Fade
        )
      }
    )

    bookmarkAction.backgroundColor = UIColor(red: 192/255.0, green: 37/255.0, blue: 37/255.0, alpha: 1)

    return bookmarkAction
  }
}

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
      bookmarkIndicatorIcon.hidden = !BookmarkRepository.sharedInstance.isBookmarked(business)

      let formatter = Yelp.Business.Formatter(business: business)

      nameLabel.text       = formatter.nameWithResultNumber(resultNumber)
      distanceLabel.text   = formatter.distanceInMiles
      reviewsCount.text    = formatter.reviewCount
      categoriesLabel.text = formatter.categories
      addressLabel.text    = formatter.address
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
  @IBOutlet weak var bookmarkIndicatorIcon: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    updateThumbnailCornerRadius()
    self.layoutMargins = UIEdgeInsetsZero
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  private func updateThumbnailCornerRadius() {
    thumbnailImageView?.layer.cornerRadius = thumbnailCornerRadius
  }

  private func setThumbnailOrDefault() {
    if let thumbnailUrl = business.thumbnailUrl?.url {
      thumbnailImageView.setImageWithURL(thumbnailUrl)
    } else {
      thumbnailImageView.image = BusinessCell.defaultThumbnailImage
    }
  }
}
