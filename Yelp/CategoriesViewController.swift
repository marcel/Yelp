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

  let topLevelCategories = Yelp.Category.allTopLevel.sort { $0.title > $1.title }

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
    let searchResultsController = segue.destinationViewController as! SearchResultsViewController

    let query = Yelp.Client.SearchQuery(
      categories: [categoryCell.category.alias]
    )

    searchResultsController.currentQuery = query
  }
}
