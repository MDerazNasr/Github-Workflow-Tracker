import AppKit
import GitPulseCore

@main
enum GitPulseMain {
    @MainActor
    private static var delegate: AppDelegate?

    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        Self.delegate = delegate
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appState: AppState?

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState = AppState()
    }

    func applicationWillTerminate(_ notification: Notification) {
        appState = nil
    }
}
