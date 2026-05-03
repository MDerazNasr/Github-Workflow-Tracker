import AppKit

enum AppIconService {
    @MainActor
    static func applyAppIcon() {
        guard let image = bundledIcon() else {
            return
        }
        NSApp.applicationIconImage = image
    }

    private static func bundledIcon() -> NSImage? {
        let urls = [
            Bundle.module.url(forResource: "GitPulse", withExtension: "icns"),
            Bundle.main.url(forResource: "GitPulse", withExtension: "icns")
        ].compactMap { $0 }

        for url in urls {
            if let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }
}
