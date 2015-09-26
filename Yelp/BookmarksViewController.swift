//
//  SecondViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class BookmarksViewController: UITableViewController {

  var businesses: [Yelp.Business] = [] {
    didSet {
      reloadData()
    }
  }

  let client = Yelp.Client()
  let bookmarkRepository = BookmarkRepository.sharedInstance

  var needsReload = true

  override func viewDidLoad() {
    super.viewDidLoad()
    prepareTableView()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // TODO Only execute this if bookmarks have changed since the last time
    // this view was loaded
    loadBookmarks()
  }

  func loadBookmarks() {
    if needsReload {
      let businessIds = bookmarkRepository.list().map { $0.businessId }

      client.businessesWithIds(businessIds) { businesses in
        self.businesses = businesses
        self.needsReload = false
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func reloadData() {
    tableView.reloadData()
  }

  func prepareTableView() {
    tableView.rowHeight          = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return businesses.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier(
      BusinessCell.identifier,
      forIndexPath: indexPath
      ) as! BusinessCell
    cell.separatorInset = UIEdgeInsetsZero

    cell.result = (indexPath.row + 1, businessAtIndexPath(indexPath))

    return cell
  }

  func businessAtIndexPath(indexPath: NSIndexPath) -> Yelp.Business {
    return businesses[indexPath.row]
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let tappedCell = sender as! BusinessCell
    let detailsViewController = segue.destinationViewController as! BusinessDetailViewController
    detailsViewController.business = tappedCell.business
  }
}

