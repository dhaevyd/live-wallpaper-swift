import SwiftUI

extension Notification.Name {
    static let wallflowSwitchTab = Notification.Name("wallflowSwitchTab")
}

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
                    NotificationCenter.default.post(name: .wallflowSwitchTab, object: NavTab.settings)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            CommandGroup(replacing: .newItem) {}
            CommandMenu("View") {
                Button("Home")     { NotificationCenter.default.post(name: .wallflowSwitchTab, object: NavTab.home) }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Explore")  { NotificationCenter.default.post(name: .wallflowSwitchTab, object: NavTab.explore) }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Library")  { NotificationCenter.default.post(name: .wallflowSwitchTab, object: NavTab.library) }
                    .keyboardShortcut("3", modifiers: .command)
                Button("Settings") { NotificationCenter.default.post(name: .wallflowSwitchTab, object: NavTab.settings) }
                    .keyboardShortcut("4", modifiers: .command)
            }
        }
    }
}
