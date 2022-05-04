//
//  ContentView.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 5/3/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection: String?
    
    var body: some View {
        NavigationView {
            SidebarView(selection: $selection)
            DetailView(selection: $selection)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var fccData = FCCDataViewModel(preview: true)
    static var previews: some View {
        ContentView(selection: nil)
            .environmentObject(fccData)

    }
}
