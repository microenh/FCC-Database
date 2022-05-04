//
//  LicenseListView.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/7/21.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var fccData: FCCDataViewModel
    @Binding var selection: String?
    
    @State private var call = ""

    var body: some View {
        VStack {
            LicenseView(selection: $selection)
            HStack {
                Spacer()
                VStack {
                    TextField("Call", text: $call) {
                        fccData.addCall(call)
                    }
                    Button("Lookup") {
                        fccData.addCall(call)
                    }
                    .disabled(call == "")
                }
                .frame(width: 100)
                Spacer()
            }
        }
        .padding([.horizontal, .bottom])
    }
}

struct DetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        let fccData = FCCDataViewModel(preview: true)
        DetailView(selection: .constant(nil))
            .environmentObject(fccData)
    }
}
