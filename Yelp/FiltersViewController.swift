//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Marcel Molina on 9/22/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate {
  // Not making it an optional because SearchQuery is a struct and can't
  // be bridge to Objective-C. I'd rather make this delegate method required
  // than have to introduce complex indirection to get the filter results back
  // to the main controller.
  func filtersViewController(
    filtersViewController: FiltersViewController,
    didUpdateFiltersForSearchQuery searchQuery: Yelp.Client.SearchQuery
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
    private let defaultSearchQuery = SearchQuery()

    init(sections: [Section]) {
      self.sections = sections
      self.sectionsByIndex = sections.reduce([:]) { (var lookupIndex, section) in
        lookupIndex[section.index] = section
        return lookupIndex
      }

      sections.forEach { section in
        let defaultValues = section.values.filter { $0.enabledByDefault }
        selections[section.index] = Selections(defaultValues)
      }
    }

    var selectionsAsSearchQuery: SearchQuery {
      return defaultSearchQuery.copy(
        sort: Array(selectionsForSection(sectionsByIndex[.Sort]!)).first.map { SortMode(rawValue: $0.raw as! Int)! },
        radius: Array(selectionsForSection(sectionsByIndex[.Distance]!)).first.map { $0.raw as! Int },
        categories: Array(selectionsForSection(sectionsByIndex[.Category]!)).map { $0.raw as! String } as [String],
        onlyDeals: Array(selectionsForSection(sectionsByIndex[.OnlyDeals]!)).first.map { $0.raw as! Bool }
      )
    }

    mutating func selectValue(value: CellValue, fromSection section: Section) {
      selections[section.index]!.insert(value)
    }

    mutating func deselectValue(value: CellValue, fromSection section: Section) {
      selections[section.index]!.remove(value)
    }

    mutating func deselectAllValuesFromSection(section: Section) {
      selections[section.index]!.removeAll()
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

  var sectionController = SectionController(
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
          CellValue(display: "10 miles",   raw: SearchQuery.milesToRadius(10), enabledByDefault: true),
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
          CellValue(display: "Distance",      raw: SortMode.Distance.rawValue, enabledByDefault: true),
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
    delegate?.filtersViewController(
      self,
      didUpdateFiltersForSearchQuery: sectionController.selectionsAsSearchQuery
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

    cell.value   = value
    cell.section = indexPath.section
    cell.onSwitch.on = sectionController.hasSelectionBeenMadeForValue(value, fromSection: section)

    return cell
  }

  // MARK: - SwitchCellDelegate

  func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
    let section = sectionController.sectionForSectionNumber(switchCell.section!)

    if value {
      if section.allowsMultipleSelections {
        sectionController.selectValue(switchCell.value, fromSection: section)
      } else {
        sectionController.deselectAllValuesFromSection(section)
        sectionController.selectValue(switchCell.value, fromSection: section)

        tableView.reloadSections(
          NSIndexSet(index: section.index.rawValue),
          withRowAnimation: UITableViewRowAnimation.Automatic
        )
      }
    } else {
      sectionController.deselectValue(switchCell.value, fromSection: section)
    }
    print("Cell \(switchCell.value.display) in section \(section.title) switched to \(value)")
    print("Current query: \(sectionController.selectionsAsSearchQuery)")
//    print("Selected categories: \(selectedCategories)")
  }

}
