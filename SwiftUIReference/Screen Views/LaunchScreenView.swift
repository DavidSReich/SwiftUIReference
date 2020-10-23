//
//  LaunchScreenView.swift
//  SwiftUIReference
//
//  Created by David S Reich on 5/2/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import SwiftUI

struct LaunchScreenView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image("Giphy_Logo")
                .resizable()
                .scaledToFit()
                .scaleEffect(0.9)
                .padding()

            HStack {
                Spacer()
                Text("Tags")
                    .font(.largeTitle)
                    .bold()
                    .scaleEffect(2.0)
                    .padding(.bottom)
                Spacer()
            }

            Spacer()

            HStack {
                Spacer()
                Text("Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer()
            }

            HStack {
                Image("PoweredBy_200px-White_HorizLogo")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.5)
            }
        }
        .onAppear(perform: goAway)
    }

    private func goAway() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isPresented = false
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    @State static var showLaunch = true

    static var previews: some View {
        Group {
            LaunchScreenView(isPresented: $showLaunch)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
            LaunchScreenView(isPresented: $showLaunch)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max (13.4)")
            LaunchScreenView(isPresented: $showLaunch)
                .previewLayout(.fixed(width: 1136, height: 640))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
            LaunchScreenView(isPresented: $showLaunch)
                .previewLayout(.fixed(width: 2688, height: 1242))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max (13.4)")
        }
    }
}
