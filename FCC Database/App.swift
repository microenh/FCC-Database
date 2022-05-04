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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                 .environmentObject(fccData)
        }
        .commands {
            SidebarCommands()
        }
        Settings {
            Preferences()
                .environmentObject(fccData)
        }
    }
}

