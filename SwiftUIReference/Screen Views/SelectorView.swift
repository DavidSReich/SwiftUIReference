//
//  SelectorView.swift
//  SwiftUIReference
//
//  Created by David S Reich on 17/12/19.
//  Copyright © 2020 Stellar Software Pty Ltd. All rights reserved.
//

import SwiftUI

struct SelectorView: View {
    @Binding var isPresented: Bool
    @Binding var selectedStrings: String

    @State private var selectKeeper = Set<String>()

    var allStrings: [String]

    var body: some View {
        NavigationView {
            VStack {
                Text(allSelectedStrings()).padding(.horizontal)
                Spacer()
                List(allStrings, id: \.self, selection: $selectKeeper) { name in
                    Text(name)
                }
                .environment(\.editMode, .constant(EditMode.active))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Select tags")
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            selectedStrings = ""
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Go!") {
                            selectedStrings = allSelectedStrings()
                            isPresented = false
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func allSelectedStrings() -> String {
        var selectedStrings = ""

        for selectedString in selectKeeper {
            let prefix = selectedStrings.isEmpty ? "" : "+"
            selectedStrings.append(prefix + selectedString)
        }

        return selectedStrings
    }
}

struct SelectorView_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var selectedStrings = ""
    static var previews: some View {
        SelectorView(isPresented: $isPresented, selectedStrings: $selectedStrings, allStrings: [
            "aaaa", "bbb", "cc", "d"
        ])
    }
}
