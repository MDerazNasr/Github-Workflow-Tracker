import AppKit
import SwiftData
import SwiftUI

@MainActor
public final class QuickPopoverWindowController {
    private weak var appState: AppState?
    private let container: ModelContainer
    private var panel: NSPanel?

    public init(appState: AppState, container: ModelContainer) {
        self.appState = appState
        self.container = container
    }

    public func toggle() {
        if panel?.isVisible == true {
            panel?.close()
            return
        }
        show()
    }

    private func show() {
        guard let appState else {
            return
        }

        let panel = panel ?? makePanel(appState: appState)
        position(panel)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    private func makePanel(appState: AppState) -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 260),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .transient]
        panel.contentViewController = NSHostingController(
            rootView: PopoverRootView()
                .modelContainer(container)
                .environment(appState)
        )
        return panel
    }

    private func position(_ panel: NSPanel) {
        guard let frame = NSScreen.main?.visibleFrame else {
            panel.center()
            return
        }

        let size = panel.frame.size
        let origin = NSPoint(
            x: frame.maxX - size.width - 16,
            y: frame.maxY - size.height - 12
        )
        panel.setFrameOrigin(origin)
    }
}
