# GitPulse Architecture Contract

GitPulse is a macOS SwiftUI menu bar app for tracking GitHub workflow activity. The implementation follows the settings addendum in `gitpulse_settings_spec.docx`.

## Stack

- Swift 6 package with a small executable target, `GitPulseApp`.
- Reusable app code lives in the `GitPulseCore` library target.
- UI uses SwiftUI, `MenuBarExtra`, and a standard SwiftUI `Settings` scene.
- Persistence uses SwiftData models with a shared `ModelContainer`.
- Tests use Swift Testing and in-memory SwiftData containers.

## Settings Model

- `AppSettings` is a single-row SwiftData model keyed by the unique id `singleton`.
- `AppSettings.ensureExists(in:)` must run during app startup before views query settings.
- Settings views bind directly to SwiftData models through `@Bindable`.
- Notification matrix rows bind to `NotificationPrefs`, not `AppSettings`.

## Settings Window

- The full settings UI is a macOS Settings window, not a menu bar popover.
- `SettingsWindowView` uses `NavigationSplitView` with these sections: General, Appearance, Account, Notifications, Repositories, Polling, Menu Bar, Shortcuts, Advanced.
- The menu bar popover remains a compact quick-access surface.

## File Boundaries

- Keep source files below 500 lines.
- Keep each settings section in its own file.
- Keep model logic in `Sources/GitPulseCore/Models`.
- Keep app bootstrap logic in `Sources/GitPulseCore/App` and `Sources/GitPulseApp`.

## Current Integration Limits

- GitHub authentication supports personal access token verification and Keychain storage.
- Default global shortcuts are registered with native macOS hotkey APIs while GitPulse is running.
- Polling, webhooks, Sparkle updates, and customizable shortcut recording still need concrete service implementations.
