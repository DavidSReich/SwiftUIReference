//
//  ImageRowView.swift
//  SwiftUIReference
//
//  Created by David S Reich on 11/12/19.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import SwiftUI

struct ImageRowView: View {
    var imageModel: ImageDataModelProtocol
    var showOnLeft: Bool

    var body: some View {
        HStack {
            placeSpacer(showMe: showOnLeft)

            GifView(imageUrlString: imageModel.imagePath)
                .frame(width: imageModel.imageSize.width, height: imageModel.imageSize.height)
                .border(Color.blue, width: 5)
                .shadow(color: .blue, radius: 10)
                .padding()
                .accessibility(label: Text(imageModel.imageTitle))
                .accessibility(hint: Text("Shows large image."))

            placeSpacer(showMe: !showOnLeft)
        }
    }

    private func placeSpacer(showMe: Bool) -> some View {
        return showMe ? AnyView(Spacer()) : AnyView(EmptyView())
    }
}

struct ImageRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ImageRowView(imageModel: BaseTestUtilities.getFishImageModel()!, showOnLeft: true)
            ImageRowView(imageModel: BaseTestUtilities.getFishImageModel()!, showOnLeft: false)
        }
    }
}
