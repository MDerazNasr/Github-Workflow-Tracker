import AppKit
import SwiftData
import SwiftUI

@MainActor
public final class StatusItemPopoverController {
    private weak var appState: AppState?
    private let container: ModelContainer
    private let statusItem: NSStatusItem
    private var panel: NSPanel?
    private var closeMonitor: Any?

    public init(appState: AppState, container: ModelContainer) {
        self.appState = appState
        self.container = container
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureStatusItem()
    }

    public func toggle() {
        if panel?.isVisible == true {
            close()
        } else {
            show()
        }
    }

    public func close() {
        panel?.orderOut(nil)
        if let closeMonitor {
            NSEvent.removeMonitor(closeMonitor)
            self.closeMonitor = nil
        }
    }

    private func show() {
        guard let appState, let button = statusItem.button else {
            return
        }

        let panel = panel ?? makePanel(appState: appState)
        position(panel, below: button)
        panel.orderFrontRegardless()
        self.panel = panel
        installCloseMonitor(for: panel)
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

    private func makePanel(appState: AppState) -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 580),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.contentViewController = NSHostingController(
            rootView: PopoverRootView()
                .modelContainer(container)
                .environment(appState)
        )
        return panel
    }

    private func position(_ panel: NSPanel, below button: NSStatusBarButton) {
        guard let buttonWindow = button.window else {
            return
        }

        let buttonFrameInWindow = button.convert(button.bounds, to: nil)
        let buttonFrame = buttonWindow.convertToScreen(buttonFrameInWindow)
        let panelSize = panel.frame.size
        let screenFrame = buttonWindow.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero

        let centeredX = buttonFrame.midX - panelSize.width / 2
        let minX = screenFrame.minX + 8
        let maxX = screenFrame.maxX - panelSize.width - 8
        let x = min(max(centeredX, minX), maxX)
        let y = buttonFrame.minY - panelSize.height - 4

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func installCloseMonitor(for panel: NSPanel) {
        if let closeMonitor {
            NSEvent.removeMonitor(closeMonitor)
        }

        closeMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self, weak panel] _ in
            guard let panel else {
                return
            }
            if !panel.frame.contains(NSEvent.mouseLocation) {
                Task { @MainActor in
                    self?.close()
                }
            }
        }
    }

    @objc private func toggleFromStatusItem() {
        toggle()
    }
}
