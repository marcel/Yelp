//
//  SecondViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import JGProgressHUD

class BookmarksViewController: BusinessesTableViewController {
  override var businesses: [Yelp.Business]! {
    didSet {
      reloadData()
    }
  }

  @IBOutlet weak var tableView: UITableView!

  var needsReload: Bool {
    let mostRecentModification    = BookmarkRepository.sharedInstance.lastModification
    let modficationSinceLastCheck = lastModification < mostRecentModification

    if modficationSinceLastCheck {
      self.lastModification = mostRecentModification
    }

    return modficationSinceLastCheck
  }

  let client = Yelp.Client()
  let bookmarkRepository = BookmarkRepository.sharedInstance
  var lastModification   = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()
    self.businesses = []
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    loadBookmarks()
  }

  func loadBookmarks(completion: ([Yelp.Business] -> ())? = .None) {
    if needsReload {
      let businessIds = bookmarkRepository.list().map { $0.businessId }

      progressIndicator.startDeterminateProgressUpTo(
        Float(businessIds.count),
        withMessage: "Loading \(businessIds.count) Bookmarks..."
      )

      client.businessesWithIds(businessIds, completion: { businesses in
        completion?(businesses)
        self.progressIndicator.endDeterminateProgress(withMessage: "Done")

        self.businesses = businesses
        self.reloadData()
      },
        perBusinessCompletion: { _ in
          self.progressIndicator.incrementDeterminateProgress(
            by: 1,
            withMessage: "\(Int(self.progressIndicator.determinateProgressTracker)) complete"
          )
        }
      )
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func reloadData() {
    tableView.reloadData()
  }

  enum Segue: String {
    case MapView
    case DetailView
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.identifier {
    case Segue.DetailView.rawValue?:
      let tappedCell = sender as! BusinessCell
      let detailsViewController = segue.destinationViewController as! BusinessDetailViewController
      detailsViewController.business = tappedCell.business
    case Segue.MapView.rawValue?:
      let navigationController = segue.destinationViewController as! UINavigationController
      let mapViewController =  navigationController.viewControllers.first! as! MapViewController

      mapViewController.businesses = businesses
    default:
      ()
    }
  }
}

