//
//  ImageDataModel.swift
//  SwiftUIReference
//
//  Created by David S Reich on 3/1/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import UIKit

protocol ImageDataModelProtocol {
    var tags: [String] { get }
    var imagePath: String { get }
    var imageSize: CGSize { get }
    var largeImagePath: String { get }
    var largeImageSize: CGSize { get }
    var imageTitle: String { get }
}

//wrapper needed because a protocol still isn't Identifiable
struct ImageDataModelProtocolWrapper: Comparable, Identifiable {
    static func < (lhs: ImageDataModelProtocolWrapper, rhs: ImageDataModelProtocolWrapper) -> Bool {
        return lhs.id.uuidString < rhs.id.uuidString
    }

    static func == (lhs: ImageDataModelProtocolWrapper, rhs: ImageDataModelProtocolWrapper) -> Bool {
        return lhs.id.uuidString == rhs.id.uuidString
    }

    // swiftlint clashes with Identifiable:id
    // swiftlint:disable identifier_name
    var id = UUID()
    // swiftlint:enable identifier_name
    var imageModel: ImageDataModelProtocol
    var showOnLeft: Bool
}

class ImageDataModel: Decodable {
    private var title: String?
    private var slug: String
    private var images: ImagesModel

    private lazy var tagsArray: [String] = {
        var tags = slug.components(separatedBy: "-")
        tags.removeLast()   //remove the id
        return tags
    }()
}

extension ImageDataModel: ImageDataModelProtocol {
    var tags: [String] {
        return tagsArray
    }

    var imagePath: String {
        return images.fixedWidth.url
    }

    var imageSize: CGSize {
        return CGSize(width: Int(images.fixedWidth.width) ?? 0, height: Int(images.fixedWidth.height) ?? 0)
    }

    var largeImagePath: String {
        return images.original.url
    }

    var largeImageSize: CGSize {
        return CGSize(width: Int(images.original.width) ?? 0, height: Int(images.original.height) ?? 0)
    }

    var imageTitle: String {
        return title ?? ""
    }
}
