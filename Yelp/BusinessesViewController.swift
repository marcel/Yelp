//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UITableViewController,
  FiltersViewControllerDelegate,
  UISearchControllerDelegate,
  UISearchBarDelegate {
  typealias SearchQuery = Yelp.Client.SearchQuery

  enum Segue: String {
    case Filters
    case DetailView
    case MapView
  }

  var businesses: [Yelp.Business] = [] {
    didSet {
      reloadData()
    }
  }

  let client = Yelp.Client()
  var progressIndicator: ProgressIndicator!
  var searchController: UISearchController!
  var currentQuery: SearchQuery = SearchQuery()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.progressIndicator = ProgressIndicator(view: view)

    prepareTableView()
//    CLLocationManager.requestAlwaysAuthorization
    self.searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    navigationItem.titleView = searchController.searchBar

    performSearch()
  }

  func performSearch(
    query: SearchQuery = SearchQuery(),
    completion: ([Yelp.Business] -> ())? = .None
  ) {
    self.currentQuery = query

    print("Performing search: \(query)")
    progressIndicator.loading()

    client.search(query) { (businesses, _) in
      self.progressIndicator.dismiss()

      if let businesses = businesses where !businesses.isEmpty {
        if let completion = completion {
          completion(businesses)
        } else {
          self.businesses = businesses
        }

        for business in businesses {
          print(business.name)
        }
      } else {
        completion?([])
        self.progressIndicator.error("No Results")
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

    let expectedDestination = targetContentOffset.memory.y + scrollView.frame.size.height
    let totalHeight = scrollView.contentSize.height
    let infiniteScrollIntensionThreshold = scrollView.frame.size.height * 0.05 // i.e. 5% of the screen

    print("total height \(totalHeight) vs expected destination \(expectedDestination)")

    if !verticalPaginationInProgress && expectedDestination > (totalHeight + infiniteScrollIntensionThreshold) {
      print("Paginating")
      verticalPaginationInProgress = true

      performSearch(currentQuery.copy(offset: businesses.count)) { businesses in
        self.businesses = self.businesses + businesses
        self.verticalPaginationInProgress = false
      }
    }
  }

  // MARK: - UISearchBarDelegate

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    if let searchTerm = searchBar.text {
      performSearch(SearchQuery(term: searchTerm))
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
      case Segue.MapView.rawValue?:
        let navigationController = segue.destinationViewController as! UINavigationController
        let mapViewController =  navigationController.viewControllers.first! as! MapViewController

        mapViewController.businesses = businesses
      default:
        ()
    }
  }

  func filtersViewController(
    filtersViewController: FiltersViewController,
    didUpdateFiltersForSearchQuery searchQuery: SearchQuery
  ) {
    print("Updated filters to \(searchQuery)")

    performSearch(searchQuery)
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
