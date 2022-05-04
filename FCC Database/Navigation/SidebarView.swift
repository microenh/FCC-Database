//
//  Sidebar.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 5/3/22.
//

import SwiftUI

struct SidebarView: View {
    
    @Binding var selection: String?
    @EnvironmentObject var data: FCCDataViewModel
    
    var body: some View {
        List(selection: $selection) {
            ForEach(data.places.keys.sorted(), id: \.self) { call in
                Text(call)
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(selection: .constant(nil))
    }
}
