//
//  ProgressIndicator.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import Foundation
import JGProgressHUD

struct ProgressIndicator {
  typealias HUD = JGProgressHUD
  let view: UIView
  let progress: HUD
  let error: HUD

  init(
    view: UIView,
    progress: HUD = HUD(style: .ExtraLight),
    error: HUD    = HUD(style: .Dark)
  ) {
    self.view     = view
    self.progress = progress
    self.error    = error

    configureDefaults()
  }

  func loading() -> HUD {
    return progress("Loading...")
  }

  func dismiss(animated: Bool = true) -> HUD {
    progress.dismissAnimated(animated)
    return progress
  }

  func progress(message: String) -> HUD {
    progress.textLabel.text = message
    progress.showInView(view, animated: true)
    return progress
  }

  func error(message: String) -> HUD {
    error.textLabel.text = message
    error.showInView(view, animated: true)
    error.dismissAfterDelay(2, animated: true)
    return error
  }

  private func configureDefaults() {
    progress.minimumDisplayTime = 0.75
    error.indicatorView = JGProgressHUDErrorIndicatorView()
  }
}