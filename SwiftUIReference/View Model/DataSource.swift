//
//  DataSource.swift
//  SwiftUIReference
//
//  Created by David S Reich on 7/3/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import Foundation
import Combine

class DataSource {
    private let networkService: NetworkService

    private var resultsStack = ResultsStack<ImageDataModelProtocolWrapper>()
    private var disposables = Set<AnyCancellable>()

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getData(tagString: String,
                 urlString: String,
                 mimeType: String,
                 completion: @escaping (_ referenceError: ReferenceError?) -> Void) {
        guard let dataPublisher = networkService.getDataPublisher(urlString: urlString, mimeType: mimeType) else {
            completion(.badURL)
            return
        }

        dataPublisher
            .flatMap(maxPublishers: .max(1)) { data -> AnyPublisher<GiphyModel, ReferenceError> in
                return data.decodeData() as AnyPublisher<GiphyModel, ReferenceError>
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                case .failure(let error):
                    completion(DataSource.mapError(error: error))
                case .finished:
                    completion(nil)
                }
            }, receiveValue: { [weak self] giphyModel in
                guard let self = self else { return }
                self.resultsStack.pushResults(title: tagString, values: giphyModel.getWrappedImageModels())
            })
            .store(in: &disposables)
    }

    class func mapError(error: ReferenceError) -> ReferenceError {
        //look for 401 and 403
        if case .responseNot200(let responseCode, let data) = error {
            if [401, 403].contains(responseCode), let data = data {
                let result: Result<MessageModel, ReferenceError> = data.decodeData()

                if case .success(let messageModel) = result {
                    let message = responseCode == 403 ?
                        "API Key might be incorrect.  Go to Settings to check it." : messageModel.message
                    return .apiNotHappy(message: message)
                }
            }
        }

        return error
    }

    var resultsDepth: Int {
        resultsStack.resultsCount
    }

    func clearAllResults() {
        resultsStack.clear()
    }

    func popResults() -> [ImageDataModelProtocolWrapper]? {
        return resultsStack.popResults()?.values
    }

    func popToTop() -> [ImageDataModelProtocolWrapper]? {
        return resultsStack.popToTop()?.values
    }

    var currentResults: [ImageDataModelProtocolWrapper]? {
        resultsStack.getLast()?.values
    }

    var penultimateTitle: String {
        return resultsStack.getPenultimate()?.title ?? ""
    }

    var title: String {
        return resultsStack.getLast()?.title ?? ""
    }

    var tagsArray: [String] {
        var tagsSet = Set<String>()

        if let imageModels = currentResults {
            for imageModel in imageModels {
                tagsSet.formUnion(imageModel.imageModel.tags)
            }
        }

        return [String](tagsSet).sorted {$0 < $1}
    }
}
