//
//  SwiftUIReferenceUITests.swift
//  SwiftUIReferenceUITests
//
//  Created by David S Reich on 1/10/20.
//

import XCTest

// UI tests must be run on a iPhone 11 Pro Max simulator (or similar) in portrait orientation
// otherwise the test will need to handle scrolling to objects not completely visible

class SwiftUIReferenceUITests: XCTestCase {

    var app: XCUIApplication?

    override func setUp() {
        continueAfterFailure = false

        XCUIApplication().launch()

        app = XCUIApplication()

        addUIInterruptionMonitor(withDescription: "Alert") { alert in
            alert.buttons["OK ... I guess"].tap()
            return true
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSettingsView() {
        guard let app = self.app else {
            XCTFail("couldn't find app")
            return
        }

        let exp = expectation(description: "Test after 10 seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: 10.0)
        if result == XCTWaiter.Result.timedOut {
            let okButton = app.alerts["Something went wrong!"].scrollViews.otherElements.buttons["OK ... I guess"]
            XCTAssertTrue(okButton.exists)
            okButton.tap()

            let settingsButton = app.buttons["Settings"]
            XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
            settingsButton.tap()
        } else {
            XCTFail("Delay interrupted")
        }

        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        let resetButton = app.buttons["Reset"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 5))
        let applyButton = app.buttons["Apply"]
        XCTAssertTrue(applyButton.waitForExistence(timeout: 5))

        resetButton.tap()

        tableTest(tablesQuery: app.tables)

        resetButton.tap()

        //make sure we reset values
        let apiTextField = app.tables.cells.textFields["GiphyAPIKeyTextField"]
        XCTAssertTrue(apiTextField.exists)
        XCTAssertEqual("adsfinflsdfl023r", apiTextField.value as? String)
    }

    private func tableTest(tablesQuery: XCUIElementQuery) {
        //settings values have been set by UserDefaultsManagerTests
        //let initialTags = "initial-Tags"
        //let giphyAPIKey = "adsfinflsdfl023r"
        //let maxNumberOfImages = 5
        //let maxNumberOfLevels = 7

        // Registration section
        XCTAssertTrue(tablesQuery.staticTexts["REGISTRATION"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["GIPHY API Key"].exists)
        XCTAssertTrue(tablesQuery.cells.buttons["Get your GIPHY key here ..."].exists)
        XCTAssertTrue(tablesQuery.staticTexts["To use GIPHY in this app you need to create a GIPHY account, " +
            "and then create an App there to get an API Key."].exists)

        let apiTextField = tablesQuery.cells.textFields["GiphyAPIKeyTextField"]
        XCTAssertTrue(apiTextField.exists)
        XCTAssertEqual("adsfinflsdfl023r", apiTextField.value as? String)

        apiTextField.tap()
        apiTextField.typeText("newApi")

        XCTAssertEqual("newApiadsfinflsdfl023r", apiTextField.value as? String)
//        XCTAssertEqual("adsfinflsdfl023rnewApi", apiTextField.value as? String)

        // Tags section
        XCTAssertTrue(tablesQuery.staticTexts["TAGS"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Starting Tags"].exists)

        let tagsTextField = tablesQuery.cells.textFields["TagsTextField"]
        XCTAssertTrue(tagsTextField.exists)
        XCTAssertEqual("initial-Tags", tagsTextField.value as? String)

        // Limits section
        XCTAssertTrue(tablesQuery.staticTexts["LIMITS"].exists)

        let imageStepper = tablesQuery.cells.otherElements["Max # of images"]
        let levelStepper = tablesQuery.cells.otherElements["Max # of levels"]
        XCTAssertTrue(imageStepper.exists)
        XCTAssertTrue(levelStepper.exists)

        XCTAssertEqual("5", imageStepper.value as? String)
        XCTAssertEqual("7", levelStepper.value as? String)

        tapStepper(stepper: imageStepper, increment: true)
        XCTAssertEqual("6", imageStepper.value as? String)
        tapStepper(stepper: imageStepper, increment: false)
        XCTAssertEqual("5", imageStepper.value as? String)

        tapStepper(stepper: levelStepper, increment: true)
        XCTAssertEqual("8", levelStepper.value as? String)
        tapStepper(stepper: levelStepper, increment: false)
        XCTAssertEqual("7", levelStepper.value as? String)
    }

    func tapStepper(stepper: XCUIElement, increment: Bool) {
        let cgVector = increment ? CGVector(dx: 0.75, dy: 0.5) : CGVector(dx: 0.25, dy: 0.5)

        let coordinate = stepper.coordinate(withNormalizedOffset: cgVector)
        coordinate.tap()
    }
}
