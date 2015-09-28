//
//  SearchResultsViewController
//  Yelp
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsViewController: BusinessesTableViewController,
  FiltersViewControllerDelegate,
  UISearchControllerDelegate,
  UISearchBarDelegate {
  typealias SearchQuery = Yelp.Client.SearchQuery

  enum Segue: String {
    case Filters
    case DetailView
    case MapView
  }

  @IBOutlet weak var tableView: UITableView!

  override var businesses: [Yelp.Business]! {
    didSet {
      reloadData()
    }
  }

  let client = Yelp.Client()
  var searchController: UISearchController!
  var currentQuery: SearchQuery = SearchQuery()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.businesses = []
    
    setupSearchBar()

    performSearch(currentQuery)
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
        // N.B. TODO currenQuery should really be a bounded stack so we can pop out a level
        // rather than scorch the earth
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func reloadData() {
    tableView.reloadData()
  }

  // MARK: - UIScrollViewDelegate

  var verticalPaginationInProgress = false
  
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

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

  func setupSearchBar() {
    self.searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    navigationItem.titleView = searchController.searchBar
  }

  // MARK: - UISearchBarDelegate

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    if let searchTerm = searchBar.text {
      performSearch(SearchQuery(term: searchTerm))
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.identifier {
      case Segue.Filters.rawValue?:
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController =  navigationController.viewControllers.first! as! FiltersViewController

        filtersViewController.delegate = self
        filtersViewController.contextualSearchQuery = currentQuery
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
}
