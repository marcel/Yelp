//
//  ReviewView.swift
//  Yelp
//
//  Created by Marcel Molina on 9/24/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class ReviewView: UIView {

  var review: Yelp.Review! {
    didSet {
      excerptLabel.text = review.excerpt
      userIconImageView.setImageWithURL(review.user.imageUrl.url)
      ratingView.setImageWithURL(review.ratingImageUrl.url)
      userNameLabel.text = review.user.name

      let formatter = Formatter(review: review)
      timeSinceReviewLabel.text = formatter.timeSinceReviewInWords()
    }
  }

  @IBOutlet weak var userIconImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var ratingView: UIImageView!
  @IBOutlet weak var timeSinceReviewLabel: UILabel!
  @IBOutlet weak var excerptLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

    layer.borderColor = UIColor.whiteColor().CGColor
    layer.borderWidth = 0.25
    layer.cornerRadius = 2
    clipsToBounds = true

    userIconImageView.layer.cornerRadius = 9
    userIconImageView.clipsToBounds = true
  }

  struct Formatter {
    let review: Yelp.Review

    func timeSinceReviewInWords() -> String {
      let timeSince = Int(NSDate().timeIntervalSinceDate(review.timeCreated))

      switch timeSince {
      case 0..<Duration.minute:
        return "\(timeSince) seconds ago"
      case Duration.minute..<Duration.hour:
        return "\(timeSince / Duration.minute) minutes ago"
      case Duration.hour..<Duration.day:
        return "\(timeSince / Duration.hour) hours ago"
      case Duration.day..<Duration.week:
        return "\(timeSince / Duration.day) days ago"
      case Duration.week..<Duration.month:
        return "\(timeSince / Duration.week) weeks ago"
      case Duration.month..<Duration.year:
        return "\(timeSince / Duration.month) months ago"
      default:
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.stringFromDate(review.timeCreated)
      }
    }

    struct Duration {
      static let minute = 60
      static let hour   = minute * minute
      static let day    = hour   * 24
      static let week   = day    * 7
      static let month  = day    * 31
      static let year   = month  * 12
    }
  }
}
