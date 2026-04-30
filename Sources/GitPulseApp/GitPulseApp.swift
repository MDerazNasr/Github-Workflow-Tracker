import GitPulseCore
import SwiftUI

@main
struct GitPulseApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            PopoverRootView()
                .modelContainer(appState.container)
                .environment(appState)
        } label: {
            MenuBarLabel()
                .modelContainer(appState.container)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsWindowView()
                .modelContainer(appState.container)
                .environment(appState)
                .frame(minWidth: 560, minHeight: 480)
        }
    }
}
