//
//  HTTPUrlResponse+ValidateTests.swift
//  SwiftUIReferenceTests
//
//  Created by David S Reich on 26/1/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import Foundation
import Combine
import XCTest

class HTTPUrlResponseValidateTests: XCTestCase {

    private var goodJSONData = Data()
    private var goodHttpUrlResponse = HTTPURLResponse()
    private var bad401HttpUrlResponse = HTTPURLResponse()
    private var bad403HttpUrlResponse = HTTPURLResponse()
    private var badHttpUrlResponse = HTTPURLResponse()
    private var goodUrlResponse = URLResponse()
    private var error: ReferenceError?
    private var dummyURL = URL(string: "https://a.b.com")
    private var dummyMimeType = "dummyMimeType"

    private var disposables = Set<AnyCancellable>()

    override func setUp() {
        goodJSONData = BaseTestUtilities.getGiphyModelData()

        if let goodHttpUrlResponse = HTTPURLResponse(url: dummyURL!, statusCode: 200, httpVersion: nil, headerFields: nil) {
            self.goodHttpUrlResponse = goodHttpUrlResponse
        } else {
            XCTFail("Couldn't create goodHTTPUrlResponse!!")
        }

        if let badHttpUrlResponse = HTTPURLResponse(url: dummyURL!, statusCode: 500, httpVersion: nil, headerFields: nil) {
            self.badHttpUrlResponse = badHttpUrlResponse
        } else {
            XCTFail("Couldn't create badHTTPUrlResponse!!")
        }

        if let bad401HttpUrlResponse = HTTPURLResponse(url: dummyURL!, statusCode: 401, httpVersion: nil, headerFields: nil) {
            self.bad401HttpUrlResponse = bad401HttpUrlResponse
        } else {
            XCTFail("Couldn't create bad401HttpUrlResponse!!")
        }

        if let bad403HttpUrlResponse = HTTPURLResponse(url: dummyURL!, statusCode: 403, httpVersion: nil, headerFields: nil) {
            self.bad403HttpUrlResponse = bad403HttpUrlResponse
        } else {
            XCTFail("Couldn't create bad403HttpUrlResponse!!")
        }

        self.goodUrlResponse = URLResponse(url: dummyURL!, mimeType: dummyMimeType, expectedContentLength: 1000, textEncodingName: nil)
    }

    func testGoodData() {
        let receiveCompletion = expectation(description: "receiveCompletion reached")

        let dataPublisher = HTTPURLResponse.validateData(data: goodJSONData, response: goodHttpUrlResponse, mimeType: nil)
        dataPublisher
            .flatMap(maxPublishers: .max(1)) { data -> AnyPublisher<GiphyModel, ReferenceError> in
                return data.decodeData() as AnyPublisher<GiphyModel, ReferenceError>
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .failure(let error):
                    XCTFail("goodHttpUrlResponse should not fail.  Instead failed with \(error).")
                    receiveCompletion.fulfill()
                case .finished:
                    //supposed to succeed ... data is tested by the caller of this in a completion handler.
                    receiveCompletion.fulfill()
                }
            }, receiveValue: { giphyModel in
                XCTAssertEqual(3, giphyModel.getWrappedImageModels().count)
            })
            .store(in: &disposables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    private func executeTest(data: Data,
                             response: URLResponse,
                             mimeType: String?,
                             completion: @escaping (_ value: Subscribers.Completion<ReferenceError>) -> Void) {
        let receiveCompletion = expectation(description: "receiveCompletion reached")

        let dataPublisher = HTTPURLResponse.validateData(data: data, response: response, mimeType: mimeType)
        dataPublisher
            .flatMap(maxPublishers: .max(1)) { data -> AnyPublisher<GiphyModel, ReferenceError> in
                return data.decodeData() as AnyPublisher<GiphyModel, ReferenceError>
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                completion(value)
                receiveCompletion.fulfill()
            }, receiveValue: { _ in
                XCTFail("urlResponse should fail, not return a value.  But it didn't fail.")
            })
            .store(in: &disposables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUrlResponse() {
        executeTest(data: goodJSONData, response: goodUrlResponse, mimeType: nil) { value in
            switch value {
            case .failure(let error):
                XCTAssertEqual(ReferenceError.notHttpURLResponse, error)
            case .finished:
                XCTFail("urlResponse should fail with notHttpURLResponse.  But it didn't fail.")
            }
        }
    }

    func testWrongMime() {
        executeTest(data: goodJSONData, response: goodUrlResponse, mimeType: "wrongMime") { value in
            switch value {
            case .failure(let error):
                if case ReferenceError.wrongMimeType(targeMimeType: let targetMimeType,
                                                     receivedMimeType: let receivedMimeType) = error {
                    XCTAssertEqual("wrongMime", targetMimeType)
                    XCTAssertEqual("dummyMimeType", receivedMimeType)
                    //supposed to fail at this point because we set "wrongMime" here
                } else {
                    XCTFail("urlResponse should fail with wrongMimeType.  Instead failed with \(error).")
                }
            case .finished:
                XCTFail("urlResponse should fail with wrongMimeType.  But it didn't fail.")
            }
        }
    }

    func test401HttpUrlResponseCode() {
        executeTest(data: BaseTestUtilities.getMessageModelData(), response: bad401HttpUrlResponse, mimeType: nil) { value in
            switch value {
            case .failure(let error):
                if case ReferenceError.apiNotHappy(message: let message) = DataSource.mapError(error: error) {
                    XCTAssertEqual("Invalid authentication credentials", message)
                } else {
                    XCTFail("urlResponse should fail with apiNotHappy.  Instead failed with \(error).")
                }
            case .finished:
                XCTFail("urlResponse should fail with apiNotHappy.  But it didn't fail.")
            }
        }
    }

    func test403HttpUrlResponseCode() {
        executeTest(data: BaseTestUtilities.getMessageModelData(), response: bad403HttpUrlResponse, mimeType: nil) { value in
            switch value {
            case .failure(let error):
                if case ReferenceError.apiNotHappy(message: let message) = DataSource.mapError(error: error) {
                    XCTAssertEqual("API Key might be incorrect.  Go to Settings to check it.", message)
                } else {
                    XCTFail("urlResponse should fail with apiNotHappy.  Instead failed with \(error).")
                }
            case .finished:
                XCTFail("urlResponse should fail with apiNotHappy.  But it didn't fail.")
            }
        }
    }

    func testBadResponseCode() {
        executeTest(data: goodJSONData, response: badHttpUrlResponse, mimeType: nil) { value in
            switch value {
            case .failure(let error):
                if case ReferenceError.responseNot200(responseCode: let responseCode, data: _) = error {
                    XCTAssertEqual(responseCode, 500)
                    //supposed to fail at this point because a we set a responseCode == 500 here.
                } else {
                    XCTFail("urlResponse should fail with responseNot200.500 error.  Instead failed with \(error).")
                }
            case .finished:
                XCTFail("urlResponse should fail with responseNot200.  But it didn't fail.")
            }
        }
    }

    func testBadData() {
        // data with count zero
        executeTest(data: Data(), response: goodHttpUrlResponse, mimeType: nil) { value in
            switch value {
            case .failure(let error):
                XCTAssertEqual(ReferenceError.noData, error)
            case .finished:
                XCTFail("urlResponse should fail with noData.  But it didn't fail.")
            }
        }
    }
}
