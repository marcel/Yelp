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

    func copy(withUpdatedValues updatedValues: [CellValue]) -> Section {
      return Section(
        title: title,
        values: updatedValues,
        index: index,
        isTogglable: isTogglable,
        allowsMultipleSelections: allowsMultipleSelections
      )
    }
  }

  struct SectionController {
    typealias SectionReverseIndex = [Section.Index: Section]
    typealias Selections = Set<CellValue>

    private static let maxPreviewSize = 3

    let sections: [Section]
    let sectionsByIndex: SectionReverseIndex
    private var selections = Dictionary<Section.Index, Selections>()
    private var toggleState = ToggleState()
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

    func isToggled(section: Section) -> Bool {
      return toggleState.isToggled(section)
    }

    mutating func toggle(section: Section, togglePerformed: ((isExpanding: Bool) -> ())?) {
      if section.isTogglable {
        togglePerformed?(isExpanding: toggleState.toggle(section))
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

    func numberOfSections() -> Int {
      let sectionsWithAtLeastOneValue = sections.filter { !$0.values.isEmpty }
      return sectionsWithAtLeastOneValue.count
    }

    func previewSizeForSection(section: Section) -> Int {
      return min(SectionController.maxPreviewSize, section.values.count)
    }

    struct ToggleState {
      private var toggled = Set<Section.Index>()

      func isToggled(section: Section) -> Bool {
        return toggled.contains(section.index)
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

  var sectionController: SectionController!

  var contextualSearchQuery: Yelp.Client.SearchQuery?
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

    sectionController = buildSectionController()
  }

  func buildSectionController() -> SectionController {
    let categoryParent = contextualSearchQuery.flatMap {
      $0.categories.first
    } ?? "restaurants"

    let categoryCells = Yelp.Category.withParent(categoryParent).map { category in
      CellValue(display: category.title, raw: category.alias)
    }

    return SectionController(
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
          values: categoryCells,
          index: .Category,
          isTogglable: true,
          allowsMultipleSelections: true
        )
      ]
    )
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let section = sectionController.sectionForIndexPath(indexPath)

    print("Selected row \(indexPath.row) in section \(section) in section \(section)")

    sectionController.toggle(section) { isExpanding in
      print("Section is toggleable and was toggled. isExpanding = \(isExpanding)")

      tableView.reloadSections(
        NSIndexSet(index: indexPath.section),
        withRowAnimation: UITableViewRowAnimation.Automatic
      )
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionController.sectionForSectionNumber(section).title
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionController.numberOfSections()
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let theSection = sectionController.sectionForSectionNumber(section)

    if theSection.isTogglable && !sectionController.isToggled(theSection) {
      if sectionController.selectionsForSection(theSection).isEmpty {
        let previewSize = sectionController.previewSizeForSection(theSection)
        return previewSize < theSection.values.count ? previewSize + 1 : previewSize
      } else {
        return 1
      }
    } else {
      return theSection.values.count
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let section = sectionController.sectionForIndexPath(indexPath)

    if sectionController.isToggled(section) || !section.isTogglable {
      return switchCellForIndexPath(indexPath)
    } else {
      if sectionController.selectionsForSection(section).isEmpty && indexPath.row < sectionController.previewSizeForSection(section) {
        return switchCellForIndexPath(indexPath)
      } else {
        return toggleCellForIndexPath(indexPath)
      }
    }
  }

  func toggleCellForIndexPath(indexPath: NSIndexPath) -> SwitchCell {
    let cell = dequeueCellAtIndexPath(indexPath)

    cell.onSwitch.hidden = true

    // TODO Consider moving to the accessoryType related callbacks
    let accessoryButton   = UIImageView(image: UIImage(named: "downward-chevron.png"))
    accessoryButton.frame = UIButton(type: UIButtonType.DetailDisclosure).frame
    cell.accessoryView    = accessoryButton

    let section        = sectionController.sectionForIndexPath(indexPath)
    let selectedValues = Array(sectionController.selectionsForSection(section))

    if let defaultValue = selectedValues.first {
      cell.value = SwitchCell.Value(display: defaultValue.display, raw: "")
    } else {
      let label = "See \(section.values.count - sectionController.previewSizeForSection(section)) more"
      cell.value = SwitchCell.Value(display: label, raw: "")
      cell.valueDisplayLabel.textColor = UIColor.grayColor()
      cell.valueDisplayLabel.center = cell.center
    }

    return cell
  }

  func dequeueCellAtIndexPath(indexPath: NSIndexPath) -> SwitchCell {
    return tableView.dequeueReusableCellWithIdentifier(
      SwitchCell.identifier,
      forIndexPath: indexPath
    ) as! SwitchCell
  }

  func switchCellForIndexPath(indexPath: NSIndexPath) -> SwitchCell {
    let cell = dequeueCellAtIndexPath(indexPath)
    cell.onSwitch.hidden = false
    cell.accessoryView   = .None
    cell.valueDisplayLabel.textColor = UIColor.blackColor()
    
    cell.delegate = self

    let section = sectionController.sectionForIndexPath(indexPath)
    let value   = sectionController.valueforIndexPath(indexPath)

    cell.value   = value
    cell.section = indexPath.section
    cell.onSwitch.on = sectionController.hasSelectionBeenMadeForValue(
      value,
      fromSection: section
    )

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
