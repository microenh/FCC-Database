//
//  FCC_DatabaseApp.swift
//  FCC Database
//
//  Created by Mark Erbaugh on 12/17/21.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // close app when last window closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct FCC_DatabaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var fccData = FCCDataViewModel()
    @State var selection: String?
    
    var body: some Scene {
        WindowGroup {
            ContentView(selection: $selection)
                 .environmentObject(fccData)
        }
        .commands {
            SidebarCommands()
        }
        Settings {
            Preferences(selection: selection)
                .environmentObject(fccData)
        }
    }
}

