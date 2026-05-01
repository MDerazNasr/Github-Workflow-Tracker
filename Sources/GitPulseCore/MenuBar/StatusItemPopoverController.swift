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
        menu.appearance = NSAppearance(named: .darkAqua)
        let width = configuredPopoverWidth()

        let hostingView = NSHostingView(
            rootView: PopoverRootView()
                .modelContainer(container)
                .environment(appState)
        )
        hostingView.frame = NSRect(x: 0, y: 0, width: width, height: 0)
        hostingView.layoutSubtreeIfNeeded()
        let fittingSize = hostingView.fittingSize
        hostingView.frame = NSRect(
            x: 0,
            y: 0,
            width: width,
            height: min(max(fittingSize.height, 260), 640)
        )
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor(
            calibratedRed: 0.067,
            green: 0.067,
            blue: 0.075,
            alpha: 1
        ).cgColor

        let item = NSMenuItem()
        item.view = hostingView
        menu.addItem(item)
        return menu
    }

    private func configuredPopoverWidth() -> CGFloat {
        let descriptor = FetchDescriptor<AppSettings>()
        let width = (try? container.mainContext.fetch(descriptor).first?.popoverWidth) ?? 420
        return CGFloat(max(width, 420))
    }

    @objc private func toggleFromStatusItem() {
        toggle()
    }
}
