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
    }
}
