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

struct SettingsWrapper: View {
    @ObservedObject var fccData: FCCData

    var body: some View {
        FCCDatabaseSettings(fccData: fccData)
    }
}

@main
struct FCC_DatabaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    

    @StateObject private var fccData = FCCData()
    
    var body: some Scene {
        WindowGroup {
            LicenseLookupView(fccData: fccData)
        }
        Settings {
            SettingsWrapper(fccData: fccData)
        }
    }
// add custom About dialog
// -----------------------
//        .commands {
//            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
//                let appName = Bundle.main.displayName!
//                Button {
//                    NSApplication.shared.orderFrontStandardAboutPanel(
//                        options: [
//                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(string: "Database Date\r\(fccData.databaseDate)"),
//                        ])
//                } label: {
//                    Text("About \(appName)")
//                }
//            }
//        }
    
}

