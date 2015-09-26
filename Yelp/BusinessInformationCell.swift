//
//  BusinessInformationCell.swift
//  Yelp
//
//  Created by Marcel Molina on 9/24/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class BusinessInformationCell: UITableViewCell {
  static let identifier = "BusinessInformationCell"

  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var headingLabel: UILabel!
  @IBOutlet weak var subHeadingLabel: UILabel!

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
  }

}
