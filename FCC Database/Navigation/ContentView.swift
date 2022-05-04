//
//  ContentView.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 5/3/22.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var selection: String?

    var body: some View {
        NavigationView {
            SidebarView(selection: $selection)
                .frame(width: 100)
            DetailView(selection: $selection)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var fccData = FCCDataViewModel(preview: true)
    static var previews: some View {
        ContentView(selection: .constant(nil))
            .environmentObject(fccData)

    }
}
