//
//  SwitchCell.swift
//  Yelp
//
//  Created by Marcel Molina on 9/25/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
  optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

// SwitchCell.Value: Equatable
func ==(lhs: SwitchCell.Value, rhs: SwitchCell.Value) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

class SwitchCell: UITableViewCell {
  static let identifier = "SwitchCell"
  
  struct Value: Hashable {
    let display: String
    let raw: AnyObject

    var hashValue: Int {
      return display.hashValue
    }
  }

  var value: Value! {
    didSet {
      valueDisplayLabel.text = value.display
    }
  }
  weak var delegate: SwitchCellDelegate?

  @IBOutlet weak var onSwitch: UISwitch!
  @IBOutlet weak var valueDisplayLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  @IBAction func switchValueChanged() {
    delegate?.switchCell?(self, didChangeValue: onSwitch.on)
  }
}
