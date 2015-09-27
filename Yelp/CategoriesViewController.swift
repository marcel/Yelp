//
//  CategoriesViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/26/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController,
  UISearchControllerDelegate, UISearchBarDelegate {
  typealias CategoryFilter = Yelp.Category -> Bool

//  - [0] : "Active Life"
//  - [1] : "Arts & Entertainment"
//  - [2] : "Automotive"
//  - [3] : "Beauty & Spas"
//  - [4] : "Bicycles"
//  - [5] : "Education"
//  - [6] : "Event Planning & Services"
//  - [7] : "Financial Services"
//  - [8] : "Food"
//  - [9] : "Health & Medical"
//  - [10] : "Home Services"
//  - [11] : "Hotels & Travel"
//  - [12] : "Local Flavor"
//  - [13] : "Local Services"
//  - [14] : "Mass Media"
//  - [15] : "Nightlife"
//  - [16] : "Pets"
//  - [17] : "Professional Services"
//  - [18] : "Public Services & Government"
//  - [19] : "Real Estate"
//  - [20] : "Religious Organizations"
//  - [21] : "Restaurants"
//  - [22] : "Shopping"
  let topLevelCategories = Yelp.Category.allTopLevel.sort { $0.title > $1.title }
//  - [0] : "restaurants"
//  - [1] : "active"
//  - [2] : "shopping"
//  - [3] : "homeservices"
//  - [4] : "food"
//  - [5] : "health"
//  - [6] : "localservices"
//  - [7] : "arts"
//  - [8] : "auto"
//  - [9] : "physicians"
//  - [10] : "professional"
//  - [11] : "japanese"
//  - [12] : "eventservices"
//  - [13] : "specialtyschools"
//  - [14] : "beautysvc"
//  - [15] : "hotelstravel"
//  - [16] : "fashion"
//  - [17] : "bars"
//  - [18] : "italian"
//  - [19] : "education"
//  - [20] : "homeandgarden"
//  - [21] : "nightlife"
//  - [22] : "realestate"
//  - [23] : "lawyers"
//  - [24] : "fitness"
//  - [25] : "transport"
//  - [26] : "publicservicesgovt"
//  - [27] : "chinese"
//  - [28] : "gourmet"
//  - [29] : "portuguese"
//  - [30] : "financialservices"
//  - [31] : "mexican"
//  - [32] : "media"
//  - [33] : "tours"
//  - [34] : "artsandcrafts"
//  - [35] : "dentists"
//  - [36] : "french"
//  - [37] : "religiousorgs"
//  - [38] : "german"
//  - [39] : "sportgoods"
//  - [40] : "pets"
//  - [41] : "c_and_mh"
//  - [42] : "petservices"
//  - [43] : "hotels"
//  - [44] : "brazilian"
//  - [45] : "festivals"
//  - [46] : "hair"
//  - [47] : "bicycles"
//  - [48] : "caribbean"
//  - [49] : "flowers"
//  - [50] : "musicinstrumentservices"
//  - [51] : "itservices"
//  - [52] : "medcenters"
//  - [53] : "latin"
//  - [54] : "turkish"
//  - [55] : "massmedia"
//  - [56] : "hairremoval"
//  - [57] : "parks"
//  - [58] : "mideastern"
//  - [59] : "donburi"
//  - [60] : "photographers"
//  - [61] : "tanning"
//  - [62] : "african"
//  - [63] : "diving"
//  - [64] : "dentalhygienists"
//  - [65] : "malaysian"
//  - [66] : "diagnosticservices"
//  - [67] : "polish"
//  - [68] : "belgian"
//  - [69] : "spanish"
//  - [70] : "localflavor"
//  - [71] : "nonprofit"
//  - [72] : "mediterranean"
//  - [73] : "arabian"
  let topCategoriesByChildren  = Yelp.Category.allByParent.keys.sort { (l,r) in
    Yelp.Category.allByParent[l]!.count > Yelp.Category.allByParent[r]!.count
  }.flatMap { Yelp.Category.allByAlias[$0] }

  var categories: [Yelp.Category] {
    return topCategoriesByChildren.filter {
      categoryFilter($0)
    }
  }

  var categoryFilter = CategoriesViewController.defaultCategoryFilter

  private static let defaultCategoryFilter: CategoryFilter = { _ in
    true
  }

  func filterFromQuery(query: String) -> CategoryFilter {
    let terms = query.characters.split { $0 == " " }.map(String.init)

    return { category in
      terms.reduce(false) { (hasMatched, term) in
        hasMatched || category.title.containsString(term)
      }
    }
  }

  var searchController: UISearchController!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSearchBar()
  }

  func setupSearchBar() {
    self.searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    navigationItem.titleView = searchController.searchBar
  }

  func reloadTable() {
    tableView.reloadData()
  }

  // MARK: - UISearchBarDelegate

  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    let whitespace     = NSCharacterSet.whitespaceCharacterSet()
    let strippedString = searchText.stringByTrimmingCharactersInSet(whitespace)
    print("Search query: '\(searchText)'")

    if strippedString.isEmpty {
      categoryFilter = CategoriesViewController.defaultCategoryFilter
    } else {
      categoryFilter = filterFromQuery(strippedString)
    }

    reloadTable()
  }

  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    categoryFilter = CategoriesViewController.defaultCategoryFilter
    reloadTable()
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      CategoryCell.identifier,
      forIndexPath: indexPath
    ) as! CategoryCell

    cell.category = categories[indexPath.row]
    
    return cell
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Top Categories"
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let categoryCell = sender as! CategoryCell
//    let destinationNavigationController = segue.destinationViewController as! UINavigationController
//    let searchResultsController = destinationNavigationController.viewControllers.first! as! SearchResultsViewController
    let searchResultsController = segue.destinationViewController as! SearchResultsViewController

    let query = Yelp.Client.SearchQuery(
      categories: [categoryCell.category.alias]
    )

    searchResultsController.currentQuery = query
  }
}
