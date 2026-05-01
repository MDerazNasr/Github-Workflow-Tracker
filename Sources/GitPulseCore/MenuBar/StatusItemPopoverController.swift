import AppKit
import SwiftData
import SwiftUI

@MainActor
public final class StatusItemPopoverController {
    private weak var appState: AppState?
    private let container: ModelContainer
    private let statusItem: NSStatusItem
    private let popover: NSPopover

    public init(appState: AppState, container: ModelContainer) {
        self.appState = appState
        self.container = container
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        configureStatusItem()
        configurePopover(appState: appState)
    }

    public func toggle() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            show()
        }
    }

    public func close() {
        popover.performClose(nil)
    }

    private func show() {
        guard let button = statusItem.button else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(
            systemSymbolName: "point.topleft.down.curvedto.point.bottomright.up",
            accessibilityDescription: "GitPulse"
        )
        button.imagePosition = .imageOnly
        button.target = self
        button.action = #selector(toggleFromStatusItem)
    }

    private func configurePopover(appState: AppState) {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 360, height: 580)
        popover.contentViewController = NSHostingController(
            rootView: PopoverRootView()
                .modelContainer(container)
                .environment(appState)
        )
    }

    @objc private func toggleFromStatusItem() {
        toggle()
    }
}
