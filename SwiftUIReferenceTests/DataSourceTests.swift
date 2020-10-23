//
//  DataSourceTests.swift
//  SwiftUIReferenceTests
//
//  Created by David S Reich on 9/3/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import XCTest
@testable import SwiftUIReference

class DataSourceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testDataSource() {
        let dataSource = DataSource(networkService: MockNetworkService())
        dataSource.getData(tagString: "data1",
                           urlString: "urlstring",
                           mimeType: "") { _ in
        }
        waitASec(howLong: 1)

        XCTAssertEqual(1, dataSource.resultsDepth)

        dataSource.getData(tagString: "data2",
                           urlString: "urlstring",
                           mimeType: "") { _ in
        }
        waitASec(howLong: 1)

        XCTAssertEqual(2, dataSource.resultsDepth)

        dataSource.getData(tagString: "data3",
                           urlString: "urlstring",
                           mimeType: "") { _ in
        }
        waitASec(howLong: 1)

        XCTAssertEqual(3, dataSource.resultsDepth)
        XCTAssertEqual("data3", dataSource.title)
        XCTAssertEqual("data2", dataSource.penultimateTitle)

        XCTAssertEqual(3, dataSource.currentResults?.count)

        XCTAssertNotNil(dataSource.currentResults)
        XCTAssertNotNil(dataSource.currentResults?[0])

        XCTAssertEqual(240.0, dataSource.currentResults?[0].imageModel.imageSize.height)
        XCTAssertEqual(550.0, dataSource.currentResults?[0].imageModel.imageSize.width)

        _ = dataSource.popResults()
        XCTAssertEqual(2, dataSource.resultsDepth)
        XCTAssertEqual("data2", dataSource.title)
        XCTAssertEqual("data1", dataSource.penultimateTitle)
    }

    private func waitASec(howLong: TimeInterval) {
        let exp = expectation(description: "Test after \(howLong) seconds")
        let result = XCTWaiter.wait(for: [exp], timeout: howLong)
        if result != XCTWaiter.Result.timedOut {
            XCTFail("Delay interrupted")
        }
    }
}
