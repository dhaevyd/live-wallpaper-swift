import SwiftUI

@main
struct WallpaperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") {
                    // Tab switch handled inside ContentView via NotificationCenter or @AppStorage;
                    // for now opening the window is sufficient — settings tab is reachable via nav bar.
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            CommandGroup(replacing: .newItem) {}   // suppress default "New Window" noise
        }
    }
}
