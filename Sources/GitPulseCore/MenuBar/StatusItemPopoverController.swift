import AppKit
import SwiftData
import SwiftUI

@MainActor
public final class StatusItemPopoverController {
    private weak var appState: AppState?
    private let container: ModelContainer
    private let statusItem: NSStatusItem
    private var menu: NSMenu?

    public init(appState: AppState, container: ModelContainer) {
        self.appState = appState
        self.container = container
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureStatusItem()
    }

    public func toggle() {
        show()
    }

    public func close() {
        menu?.cancelTracking()
    }

    private func show() {
        guard let appState else {
            return
        }

        let menu = makeMenu(appState: appState)
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
        self.menu = menu
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

    private func makeMenu(appState: AppState) -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let hostingView = NSHostingView(
            rootView: PopoverRootView()
                .modelContainer(container)
                .environment(appState)
        )
        hostingView.frame = NSRect(x: 0, y: 0, width: 360, height: 580)

        let item = NSMenuItem()
        item.view = hostingView
        menu.addItem(item)
        return menu
    }

    @objc private func toggleFromStatusItem() {
        toggle()
    }
}
