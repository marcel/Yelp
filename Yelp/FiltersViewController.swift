//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/22/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
  optional func filtersViewController(
    filtersViewController: FiltersViewController,
    didUpdateFilters filters: FiltersViewController.CategorySelection
  )
}

class FiltersViewController: UITableViewController, SwitchCellDelegate {
  typealias CategorySelection = Set<Yelp.Category.Alias>
  typealias SearchQuery = Yelp.Client.SearchQuery
  typealias SortMode    = Yelp.Client.SortMode
  typealias CellValue   = SwitchCell.Value

  struct Section {
    enum Index: Int {
      case OnlyDeals = 0, Distance, Sort, Category
    }

    let title: String?
    let values: [CellValue]
    let index: Index
    let isTogglable: Bool
    let allowsMultipleSelections: Bool
  }

  struct SectionController {
    typealias SectionReverseIndex = [Section.Index: Section]
    typealias Selections = Set<CellValue>

    let sections: [Section]
    let sectionsByIndex: SectionReverseIndex
    private var selections = Dictionary<Section.Index, Selections>()

    private let toggled = Set<Section.Index>()

    init(sections: [Section]) {
      self.sections = sections
      self.sectionsByIndex = sections.reduce([:]) { (var lookupIndex, section) in
        lookupIndex[section.index] = section
        return lookupIndex
      }

      sections.forEach { section in
        selections[section.index] = Selections()
      }
    }

    mutating func selectValue(value: CellValue, fromSection section: Section) {
      selections[section.index]!.insert(value)
    }

    mutating func deselectValue(value: CellValue, fromSection section: Section) {
      selections[section.index]!.remove(value)
    }

    func hasSelectionBeenMadeForValue(value: CellValue, fromSection section: Section) -> Bool {
      return selectionsForSection(section).contains(value)
    }

    private func selectionsForSection(section: Section) -> Selections {
      return selections[section.index]!
    }

    func sectionForIndexPath(indexPath: NSIndexPath) -> Section {
      return sectionForSectionNumber(indexPath.section)
    }

    func sectionForSectionNumber(sectionNumber: Int) -> Section {
      return sectionsByIndex[Section.Index(rawValue: sectionNumber)!]!
    }

    func valuesForIndexPath(indexPath: NSIndexPath) -> [CellValue] {
      let section = sectionForIndexPath(indexPath)
      return section.values
    }

    func valueforIndexPath(indexPath: NSIndexPath) -> CellValue {
      return sectionForIndexPath(indexPath).values[indexPath.row]
    }

    static let togglable = Set<Section.Index>([.Distance, .Sort])

    struct ToggleState {
      private var toggled = Set<Section.Index>()

      func isToggled(section: Section) -> Bool {
        return toggled.contains(section.index)
      }

      func canBeToggled(section: Section) -> Bool {
        return togglable.contains(section.index)
      }

      mutating func toggle(section: Section) -> Bool {
        if isToggled(section) {
          toggled.remove(section.index)
          return false
        } else {
          toggled.insert(section.index)
          return true
        }
      }
    }
  }

  let sectionController = SectionController(
    sections: [
      Section(
        title: .None,
        values: [CellValue(display: "Offering a Deal", raw: true)],
        index: .OnlyDeals,
        isTogglable: false,
        allowsMultipleSelections: true
      ),
      Section(
        title: "Distance",
        values: [
          CellValue(display: "0.25 miles", raw: SearchQuery.milesToRadius(0.25)),
          CellValue(display: "1 mile",     raw: SearchQuery.milesToRadius(1)),
          CellValue(display: "5 miles",    raw: SearchQuery.milesToRadius(5)),
          CellValue(display: "10 miles",   raw: SearchQuery.milesToRadius(10)),
          CellValue(display: "25 miles",   raw: SearchQuery.milesToRadius(25))
        ],
        index: .Distance,
        isTogglable: true,
        allowsMultipleSelections: false
      ),
      Section(
        title: "Sort By",
        values: [
          CellValue(display: "Best Match",    raw: SortMode.BestMatched.rawValue),
          CellValue(display: "Distance",      raw: SortMode.Distance.rawValue),
          CellValue(display: "Highest Rated", raw: SortMode.HighestRated.rawValue)
        ],
        index: .Sort,
        isTogglable: true,
        allowsMultipleSelections: false
      ),
      Section(
        title: "Category",
        values: Yelp.Category.withParent("restaurants").map { category in
          CellValue(display: category.title, raw: category.alias)
        },
        index: .Category,
        isTogglable: true,
        allowsMultipleSelections: true
      )
    ]
  )

  var selectedCategories = CategorySelection()

  var delegate: FiltersViewControllerDelegate?

  @IBAction func onCancelButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func onSearchButton(sender: AnyObject) {
    delegate?.filtersViewController?(
      self,
      didUpdateFilters: selectedCategories
    )
    dismissViewControllerAnimated(true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  // TODO

//  override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//    <#code#>
//  }
//
//  override func tableView(tableView: UITableView, accessoryTypeForRowWithIndexPath indexPath: NSIndexPath) -> UITableViewCellAccessoryType {
//    <#code#>
//  }

  override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//    let section = sectionForIndexPath(indexPath)

//    if toggleState.canBeToggled(section) {
//
//    } else {
//
//    }
  }

  // Don't need this if I just use the viewForFooterSection
//  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//    return sectionForIndexPath(indexPath).map { $0.title }
//  }

//  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//    <#code#>
//  }

//  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    <#code#>
//  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionController.sectionForSectionNumber(section).title
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionController.sections.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sectionController.sectionForSectionNumber(section).values.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      SwitchCell.identifier,
      forIndexPath: indexPath
    ) as! SwitchCell

    cell.delegate = self

    let section = sectionController.sectionForIndexPath(indexPath)
    let value   = sectionController.valueforIndexPath(indexPath)

    cell.value = value
    cell.onSwitch.on = sectionController.hasSelectionBeenMadeForValue(value, fromSection: section)

//    switch indexPath.section {
//    case Section.OnlyDeals.rawValue:
//      cell.onSwitch.on = false
//      let category = restaurantCategories.last!
//
//      cell.value = SwitchCell.Value(display: category.title, raw: category.alias)
//    case Section.Category.rawValue:
//      let category = restaurantCategories[indexPath.row]
//
//      cell.onSwitch.on = selectedCategories.contains(category.alias)
//      cell.value       = SwitchCell.Value(display: category.title, raw: category.alias)
//    default:
//      cell.onSwitch.on = false
//      let category = restaurantCategories[restaurantCategories.count - indexPath.section]
//      cell.value       = SwitchCell.Value(display: category.title, raw: category.alias)
//    }

    return cell
  }

  // MARK: - SwitchCellDelegate

  func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
//    let alias = switchCell.value.raw as! String
//
//    if value {
//      selectedCategories.insert(alias)
//    } else {
//      selectedCategories.remove(alias)
//    }

    print("Category \(switchCell.value.display) switched to \(value)")
//    print("Selected categories: \(selectedCategories)")
  }

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      // Return false if you do not want the item to be re-orderable.
      return true
  }
  */

}
