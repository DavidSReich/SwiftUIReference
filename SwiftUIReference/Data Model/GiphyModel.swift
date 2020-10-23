//
//  GiphyModel.swift
//  SwiftUIReference
//
//  Created by David S Reich on 3/1/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

struct GiphyModel: Decodable {
    var meta: MetaModel
    var data: [ImageDataModel]

    func getWrappedImageModels() -> [ImageDataModelProtocolWrapper] {
        var imageModels = [ImageDataModelProtocolWrapper]()

        for fullItem in data {
            //alternate left and right
            imageModels.append(ImageDataModelProtocolWrapper(imageModel: fullItem, showOnLeft: imageModels.count.isMultiple(of: 2)))
        }

        imageModels.sort()
        return imageModels
    }
}
