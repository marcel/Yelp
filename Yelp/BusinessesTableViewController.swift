//
//  BusinessesTableViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class BusinessesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var businesses: [Yelp.Business]!
  var progressIndicator: ProgressIndicator!

  override func viewDidLoad() {
    self.progressIndicator = ProgressIndicator(view: navigationController!.view)
  }

  func prepareCell(cell: BusinessCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.separatorInset = UIEdgeInsetsZero
    cell.result = (indexPath.row + 1, businessAtIndexPath(indexPath))
    // Subclasses implement this to further configure the cell
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      BusinessCell.identifier,
      forIndexPath: indexPath
    ) as! BusinessCell

    prepareCell(cell, forRowAtIndexPath: indexPath)

    return cell
  }

  func businessAtIndexPath(indexPath: NSIndexPath) -> Yelp.Business {
    return businesses[indexPath.row]
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Kludgy work around to ensure this is set since there is no delegate method I can find
    // to set it and this abstract super class doesn't have a reference to the table view.
    tableView.estimatedRowHeight = 120

    return businesses.count
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    return [
      BookmarkRowAction.tableView(
        tableView,
        bookmarkActionForRowAtIndexPath: indexPath,
        business: businessAtIndexPath(indexPath)
      )
    ]
  }
}
