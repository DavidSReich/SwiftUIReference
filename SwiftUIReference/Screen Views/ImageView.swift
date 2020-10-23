//
//  ImageView.swift
//  SwiftUIReference
//
//  Created by David S Reich on 11/12/19.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    @Binding var imageModel: ImageDataModelProtocol?

    @State var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var body: some View {
        ZStack {
            Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .top, endPoint: .bottom))

            if let imageModel = imageModel {
                GifView(imageUrlString: imageModel.largeImagePath)
                    //this frame is necessary to set the frame for the border and shadow
                    //this is necessary because GifView is a UIImageView inside a UIViewRepresentable
                    //and doesn't size itself responsively like a normal SwiftUI Image
                    .frame(width: imageModel.largeImageSize.width, height: imageModel.largeImageSize.height)
                    .border(Color.orange, width: 5)
                    .shadow(color: .orange, radius: 15)
                    .scaleEffect(fitImageInScreen(size: UIScreen.main.bounds.size))
                    //this frame is necessary to keep the image inside the width
                    .frame(width: UIScreen.main.bounds.width)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(imageModel?.imageTitle ?? "No Image?")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            //even though orientation is not used this will trigger a re-layout with the new size
            orientation = UIDevice.current.orientation
        }
    }

    private func fitImageInScreen(size: CGSize) -> CGFloat {
        guard let imageModel = imageModel else {
            return 1
        }
        guard size.height > 44,
              size.width != 0 else {
            return 1
        }

        let screenHeight = size.height - 44
        let screenWidth = size.width

        let imageHeight = imageModel.largeImageSize.height
        let imageWidth = imageModel.largeImageSize.width

        let image2ScreenHeightRatio = imageHeight / screenHeight
        let image2ScreenWidthRatio = imageWidth / screenWidth
        let maxImage2ScreenRatio = max(image2ScreenWidthRatio, image2ScreenHeightRatio)

        let scaleAmount = 0.9 / maxImage2ScreenRatio

        return scaleAmount
    }
}

struct ImageView_Previews: PreviewProvider {
    @State static var imageModel: ImageDataModelProtocol? = BaseTestUtilities.getFishImageModel()
    static var previews: some View {
        ImageView(imageModel: $imageModel)
    }
}
