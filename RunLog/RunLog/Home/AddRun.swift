//
//  AddRun.swift
//  RunLog
//
//  Created by Alex N on 4/12/21.
//

import SwiftUI

struct AddRun: View {
    static let DefaultRunName = "My Run"
    
    @State var name = ""
    @State var date = Date()
    
    let onComplete: (String, Date) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Run Name")) {
                    TextField("Run Name", text: $name)
                }
                Section {
                    Button(action: addRunAction) {
                        Text("Add Run")
                    }
                }
            }
            .navigationBarTitle(Text("Add Run"), displayMode: .inline)
        }
    }
    
    private func addRunAction() {
        onComplete(
            name.isEmpty ? AddRun.DefaultRunName : name,
            date
        )
    }
}
