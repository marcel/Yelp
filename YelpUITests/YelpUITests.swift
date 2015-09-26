//
//  YelpUITests.swift
//  YelpUITests
//
//  Created by Marcel Molina on 9/21/15.
//  Copyright © 2015 Marcel Molina. All rights reserved.
//

import XCTest

class YelpUITests: XCTestCase {

  var app: XCUIApplication!
  override func setUp() {
    super.setUp()
      
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    app = XCUIApplication()
    app.launch()

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }


  func testEnteringSearchQueryAndExecutingSearchUpdatesTableWithResults() {
    let originalFirstCell = firstCell(app.tables)

    XCTAssert(app.searchFields.element.exists)
    app.searchFields.element.tap()
    XCTAssert(app.keyboards.element.exists)
    app.searchFields.element.typeText("sashimi")
    app.keyboards.buttons["Search"].tap()
    XCTAssertNotEqual(businessName(originalFirstCell), businessName(firstCell(app.tables)))
  }

  func testEnteringSearchQueryButCancellingSearchDoesNotUpdateTable() {
    let originalFirstCell = firstCell(app.tables)

    XCTAssert(app.searchFields.element.exists)
    app.searchFields.element.tap()
    XCTAssert(app.keyboards.element.exists)
    app.searchFields.element.typeText("sashimi")
    app.navigationBars.buttons["Cancel"].tap()
    XCTAssertEqual(businessName(originalFirstCell), businessName(firstCell(app.tables)))
  }

  private func businessName(cell: XCUIElement) -> String {
    return cell.staticTexts.elementBoundByIndex(0).label
  }

  private func firstCell(table: XCUIElementQuery) -> XCUIElement {
    return table.cells.elementBoundByIndex(0)
  }


    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testExample() {
//        // Use recording to get started writing UI tests.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }

}
