import AppKit
import SwiftData
import SwiftUI

@MainActor
final class SettingsWindowController {
    private weak var appState: AppState?
    private let container: ModelContainer
    private var window: NSWindow?

    init(appState: AppState, container: ModelContainer) {
        self.appState = appState
        self.container = container
    }

    func show() {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        guard let appState else {
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "GitPulse Settings"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 700, height: 520)
        window.appearance = NSAppearance(named: .darkAqua)
        window.backgroundColor = NSColor(calibratedRed: 0.067, green: 0.067, blue: 0.075, alpha: 1)
        window.contentViewController = NSHostingController(
            rootView: SettingsWindowView()
                .modelContainer(container)
                .environment(appState)
        )
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }
}
