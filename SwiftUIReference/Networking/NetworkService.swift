//
//  NetworkService.swift
//  SwiftUIReference
//
//  Created by David S Reich on 6/3/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import Foundation

//this is a wrapper around URLSession.dataTaskPublisher (which is an extension that we can't override in a mock)
//this can be overridden for injection of a mock during unit testing.

class NetworkService {
    //and this can't be static or it can't be injected, and then it couldn't be mocked either
    func getDataPublisher(urlString: String, mimeType: String) -> DataPublisher? {

        guard let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlString) else {
            print("Cannot make URL")
            // .badURL
            return nil
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error in
                .dataTask(error: error)
            }
            .flatMap(maxPublishers: .max(1)) { result in
                return HTTPURLResponse.validateData(data: result.data, response: result.response, mimeType: mimeType)
            }
            .eraseToAnyPublisher()
    }
}
