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
  let determinate: HUD

  var determinateProgressTracker: Float = 0
  private var targetTotal: Float = 0

  init(
    view: UIView,
    progress: HUD    = HUD(style: .ExtraLight),
    error: HUD       = HUD(style: .Dark),
    determinate: HUD = HUD(style: .ExtraLight)
  ) {
    self.view        = view
    self.progress    = progress
    self.error       = error
    self.determinate = determinate

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

  mutating func startDeterminateProgressUpTo(total: Float, withMessage message: String? = .None) {
    determinateProgressTracker = 0
    targetTotal = total

    determinate.textLabel.text = message
    determinate.showInView(view)
    determinate.layoutChangeAnimationDuration = 0.0
  }

  mutating func incrementDeterminateProgress(
    by amount: Float?,
    withMessage message: String? = .None
  ) {
    determinateProgressTracker += amount ?? 1
    determinate.setProgress(percentDone, animated: false)
    determinate.detailTextLabel.text = message
  }

  mutating func endDeterminateProgress(withMessage message: String? = .None) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), {
      self.determinate.textLabel.text = message
      self.determinate.detailTextLabel.text = .None
      self.determinate.layoutChangeAnimationDuration = 0.3
    })

    determinate.dismissAfterDelay(1, animated: true)

    determinateProgressTracker = 0
    targetTotal = 0
  }

  private var percentDone: Float {
    return determinateProgressTracker / targetTotal
  }

  private func configureDefaults() {
    progress.minimumDisplayTime = 0.75
    error.indicatorView = JGProgressHUDErrorIndicatorView()
    determinate.indicatorView = JGProgressHUDIndeterminateIndicatorView(HUDStyle: determinate.style)
  }
}