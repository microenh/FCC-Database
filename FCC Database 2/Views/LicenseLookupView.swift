//
//  LicenseListView.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/7/21.
//

import SwiftUI

struct LicenseLookupView: View {
    @ObservedObject var fccData: FCCData

    @State private var call = ""

    var body: some View {
        VStack {
            LicenseView(data: fccData)
            HStack {
                Spacer()
                VStack {
                    TextField("Call", text: $call, onCommit: {
                        fccData.byCallsignWithAddress(call)
                    })
                    Button("Lookup") {
                        fccData.byCallsignWithAddress(call)
                    }
                    .disabled(call == "")
                }
                .frame(width: 100)
                Spacer()
            }
        }
        .padding()
    }
}

struct LicenseListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let fccData = FCCData()
        LicenseLookupView(fccData: fccData)
    }
}
