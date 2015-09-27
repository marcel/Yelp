//
//  CategoryCell.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
  static let identifier = "CategoryCell"

  var category: Yelp.Category! {
    didSet {
      nameLabel.text = category.title
      iconImage.image = UIImage(named: "\(category.alias).png")
    }
  }
  
  @IBOutlet weak var iconImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}
