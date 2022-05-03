//
//  ContentView.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 5/3/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            DetailView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let fccData = FCCData(preview: true)
        ContentView()
            .environmentObject(fccData)

    }
}
