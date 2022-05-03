//
//  LicenseListView.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 11/7/21.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var fccData: FCCData
    
    @State private var call = ""

    var body: some View {
        VStack {
            LicenseView()
            HStack {
                Spacer()
                VStack {
                    TextField("Call", text: $call) {
                        fccData.byCallsignWithAddress(call)
                    }
                    Button("Lookup") {
                        fccData.byCallsignWithAddress(call)
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
        let fccData = FCCData(preview: true)
        DetailView()
            .environmentObject(fccData)
    }
}
