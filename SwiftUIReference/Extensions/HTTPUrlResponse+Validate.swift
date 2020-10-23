//
//  HTTPUrlResponse+Validate.swift
//  SwiftUIReference
//
//  Created by David S Reich on 22/1/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import Foundation
import Combine

public typealias DataPublisher = AnyPublisher<Data, ReferenceError>

extension HTTPURLResponse {
    static func validateData(data: Data, response: URLResponse, mimeType: String?) -> DataPublisher {
        let result = validateDataError(data: data, response: response, mimeType: mimeType)

        switch result {
        case .success(let data):
            return Just(data)
                .setFailureType(to: ReferenceError.self)
                .eraseToAnyPublisher()
        case .failure(let referenceError):
            print("\(referenceError)")
            return Fail(error: referenceError).eraseToAnyPublisher()
        }
    }

    static func validateDataError(data: Data?, response: URLResponse?, mimeType: String?) -> Result<Data, ReferenceError> {
        guard let response = response else {
            print("No response.")
            return .failure(.noResponse)
        }

        if let mimeType = mimeType,
            let mime = response.mimeType,
            mime != mimeType {
            print("Response type not \(mimeType): \(String(describing: response.mimeType))")
            return .failure(.wrongMimeType(targeMimeType: mimeType, receivedMimeType: response.mimeType ?? "missing type"))
        }

        guard let urlResponse = response as? HTTPURLResponse else {
            print("Response not URLResponse: \(response).")
            return .failure(.notHttpURLResponse)
        }

        guard urlResponse.statusCode == 200 else {
            print("Bad response statusCode = \(urlResponse.statusCode)")
            return .failure(.responseNot200(responseCode: urlResponse.statusCode, data: data))
        }

        guard let data = data, data.count > 0 else {
            print("No data.")
            return .failure(.noData)
        }

        return .success(data)
    }
}
