//
//  SettingsView.swift
//  SwiftUIReference
//
//  Created by David S Reich on 7/1/20.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import SwiftUI

/*
 Accessibility stuff set below trying to make it possible to do "useful" UITests.
 This does not appear to be possible with the current versions of Xcode, tools, and macOS.
 */

struct SettingsView: View {
    @Binding var isPresented: Bool
    @Binding var settingsChanged: Bool

    // yeah - this is redundant, since UserDefaultsManager can read and write to UserDefaults
    // but this illustrates using @AppStorage.
    @AppStorage(UserDefaultsManager.userSettingsKey) var userSettingsData: Data =
        UserDefaultsManager.getUserSettings().getUserSettingsData()

    @State var userSettings = UserDefaultsManager.getUserSettings()
    @State var originalUserSettings = UserDefaultsManager.getUserSettings()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Registration").font(.subheadline)) {
                    HStack {
                        Text("GIPHY API Key")
                        TextField("", text: $userSettings.giphyAPIKey).multilineTextAlignment(.trailing)
                            .accessibility(identifier: "GiphyAPIKeyTextField")
                    }
                    Link(destination: URL(string: "https://developers.giphy.com/dashboard/?create=true")!) {
                        HStack {
                            Text("Get your GIPHY key here ...")
                            Spacer()
                            Image(systemName: "link.circle.fill")
                        }
                    }
                    HStack {
                        Text("To use GIPHY in this app you need to create a GIPHY account, " +
                            "and then create an App there to get an API Key.")
                        Spacer()
                    }
                }
                Section(header: Text("Tags").font(.subheadline)) {
                    HStack {
                        Text("Starting Tags")
                        TextField("", text: $userSettings.initialTags).multilineTextAlignment(.trailing)
                            .accessibility(identifier: "TagsTextField")
                    }
                }
                Section(header: Text("Limits").font(.subheadline)) {
                    StepperField(title: "Max # of images",
                                 value: $userSettings.maxNumberOfImages,
                                 range: 5...30,
                                 accessibilityLabel: "Max number of images")
                    StepperField(title: "Max # of levels",
                                 value: $userSettings.maxNumberOfLevels,
                                 range: 5...20,
                                 accessibilityLabel: "Max number of levels")
                }
            }
            .listStyle(GroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    HStack {
                        Button("Reset") {
                            userSettings = originalUserSettings
                        }

                        Button("Apply") {
                            if originalUserSettings != userSettings {
                                userSettingsData = userSettings.getUserSettingsData()
                                settingsChanged = true
                            }
                            isPresented = false
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var settingsChanged = false

    static var previews: some View {
        SettingsView(isPresented: $isPresented, settingsChanged: $settingsChanged)
    }
}

//move this to its own file
struct StepperField: View {
    var title: String
    var value: Binding<Int>
    var range: ClosedRange<Int>
    var accessibilityLabel: String

    var body: some View {
        Stepper(value: value, in: range) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue)")
            }
        }
        .accessibility(identifier: title)
        .accessibility(value: Text("\(value.wrappedValue)"))
        // The value of a SwiftUI Stepper view is not "inspectable" at run-time.
        // We need to set the accessibility value so that we can UI test.
    }
}
