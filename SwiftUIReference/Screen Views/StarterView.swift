//
//  StarterView.swift
//  SwiftUIReference
//
//  Created by David S Reich on 5/2/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import SwiftUI

struct StarterView: View {
    @State private var showLaunchScreen = true

    let mainViewModel = MainViewModel(dataSource: DataSource(networkService: NetworkService()),
                                              userSettings: UserDefaultsManager.getUserSettings())

    var body: some View {
        Group {
            if showLaunchScreen {
                LaunchScreenView(isPresented: $showLaunchScreen)
            } else {
                MainView(mainViewModel: mainViewModel)
            }
        }
    }
}

struct StarterView_Previews: PreviewProvider {
    static var previews: some View {
        StarterView()
    }
}
