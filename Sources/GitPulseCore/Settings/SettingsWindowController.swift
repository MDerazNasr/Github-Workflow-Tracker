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
            applyAppearance(currentAppearance())
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
        applyAppearance(currentAppearance(), to: window)
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

    func applyAppearance(_ appearance: AppAppearance) {
        guard let window else {
            return
        }
        applyAppearance(appearance, to: window)
    }

    private func applyAppearance(_ appearance: AppAppearance, to window: NSWindow) {
        window.appearance = appearance.nsAppearance
        window.backgroundColor = GitPulseColors.backgroundNSColor(for: appearance)
    }

    private func currentAppearance() -> AppAppearance {
        let descriptor = FetchDescriptor<AppSettings>()
        return (try? container.mainContext.fetch(descriptor).first?.appearance) ?? .system
    }
}
