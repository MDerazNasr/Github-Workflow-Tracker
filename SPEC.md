# GitPulse Architecture Contract

GitPulse is a macOS SwiftUI menu bar app for tracking GitHub workflow activity. The implementation follows the settings addendum in `gitpulse_settings_spec.docx`.

## Stack

- Swift 6 package with a small executable target, `GitPulseApp`.
- Reusable app code lives in the `GitPulseCore` library target.
- UI uses SwiftUI and `MenuBarExtra`, with a custom dark settings `NSWindow`.
- Persistence uses SwiftData models with a shared `ModelContainer`.
- Tests use Swift Testing and in-memory SwiftData containers.

## Settings Model

- `AppSettings` is a single-row SwiftData model keyed by the unique id `singleton`.
- `AppSettings.ensureExists(in:)` must run during app startup before views query settings.
- Settings views bind directly to SwiftData models through `@Bindable`.
- Notification matrix rows bind to `NotificationPrefs`, not `AppSettings`.

## UI Contract

- `GitPulse UI Spec - Claude.docx` supersedes prior native macOS UI guidance.
- Popover and settings use a hardcoded dark terminal palette and monospaced typography.
- Do not use SwiftUI `Form`, `.formStyle(.grouped)`, adaptive system colors, native toggles, or native pickers for app UI.
- The activity popover uses header, filter pills, repository sections, and footer.
- The full settings UI is a custom dark window with a custom sidebar and detail area.
- Settings sections are General, Appearance, Account, Notifications, Repositories, Polling, Menu Bar, Shortcuts, Advanced.

## File Boundaries

- Keep source files below 500 lines.
- Keep each settings section in its own file.
- Keep model logic in `Sources/GitPulseCore/Models`.
- Keep app bootstrap logic in `Sources/GitPulseCore/App` and `Sources/GitPulseApp`.

## Current Integration Limits

- GitHub authentication supports personal access token verification and Keychain storage.
- Authored open pull requests are fetched from GitHub GraphQL and stored in SwiftData for the menu popover.
- Default global shortcuts are registered with native macOS hotkey APIs while GitPulse is running.
- Webhooks, Sparkle updates, notifications delivery, and customizable shortcut recording still need concrete service implementations.
