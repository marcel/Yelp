//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import MapKit
import JGProgressHUD

class BusinessesViewController: UITableViewController,
  FiltersViewControllerDelegate,
  UISearchControllerDelegate,
  UISearchBarDelegate {

  enum Segue: String {
    case Filters
    case DetailView
  }

  var businesses: [Yelp.Business] = [] {
    didSet {
      reloadData()
    }
  }

  let client = Yelp.Client()

  let progressIndicator     = JGProgressHUD(style: JGProgressHUDStyle.ExtraLight)
  let errorMessageIndicator = JGProgressHUD(style: JGProgressHUDStyle.Dark)

  var searchController: UISearchController!

  override func viewDidLoad() {
    super.viewDidLoad()
    prepareTableView()
//    CLLocationManager.requestAlwaysAuthorization
    self.searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    navigationItem.titleView = searchController.searchBar

    performSearch()
  }

  func displayProgressIndicatorWithMessage(message: String) {
    progressIndicator.minimumDisplayTime = 0.75
    progressIndicator.textLabel.text = message
    progressIndicator.showInView(view, animated: true)
  }

  func displayErrorMessage(message: String) {
    errorMessageIndicator.textLabel.text = message
    errorMessageIndicator.indicatorView = JGProgressHUDErrorIndicatorView()
    errorMessageIndicator.showInView(view, animated: true)
    errorMessageIndicator.dismissAfterDelay(2, animated: true)
  }

  func performSearch(term: String = "", categories: [Yelp.Category.Alias] = []) {
    print("Performing search: \(categories)")
    displayProgressIndicatorWithMessage("Loading...")

    client.search(Yelp.Client.SearchQuery(term: term, categories: categories)) { (businesses, error) in
      self.progressIndicator.dismissAnimated(true)

      if let businesses = businesses where !businesses.isEmpty {
        self.businesses = businesses

        for business in businesses {
          print(business.name)
        }
      } else {
        self.displayErrorMessage("No Results")
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func reloadData() {
    tableView.reloadData()
  }

  func prepareTableView() {
    tableView.rowHeight          = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
  }

  // MARK: - UIScrollViewDelegate

  var verticalPaginationInProgress = false
  
  override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    // targetContentOffset.memory.y + scrollView.frame.size.height >= scrollView.contentSize.height
    print("scrollViewWillEndDragging with content offset ", targetContentOffset.debugDescription)
  }

  // MARK: - UISearchBarDelegate

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    if let searchTerm = searchBar.text {
      performSearch(searchTerm)
    }
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
    switch segue.identifier {
      case Segue.Filters.rawValue?:
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController =  navigationController.viewControllers.first! as! FiltersViewController

        filtersViewController.delegate = self
      case Segue.DetailView.rawValue?:
        let tappedCell = sender as! BusinessCell
        let detailsViewController = segue.destinationViewController as! BusinessDetailViewController
        detailsViewController.business = tappedCell.business
      default:
        ()
    }
  }

  func filtersViewController(
    filtersViewController: FiltersViewController,
    didUpdateFilters filters: FiltersViewController.CategorySelection
  ) {
    print("Updated filters to: \(filters)")
    performSearch(categories: Array(filters))
  }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
