// PLAK DIT IN EEN NIEUW XCODE MACOS APP PROJECT
// File -> New -> Project -> macOS -> App

import SwiftUI
import Cocoa

@main
struct ShortcutCounterApp: App {
    var body: some Scene {
        MenuBarExtra("⌨️", systemImage: "keyboard") {
            VStack {
                Text("Test App")
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
            .onAppear {
                print("🚀 APP STARTED")
            }
        }
        .menuBarExtraStyle(.window)
    }
}