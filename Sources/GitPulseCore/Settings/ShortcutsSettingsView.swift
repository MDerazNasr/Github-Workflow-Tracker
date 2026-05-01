import AppKit
import SwiftData
import SwiftUI

struct ShortcutsSettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Query private var settingsArr: [AppSettings]
    @State private var recordingAction: GlobalShortcutAction?
    @State private var recorderMonitor: Any?
    @State private var validationMessage: String?

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "global shortcuts", isFirst: true)
            SettingsGroup {
                ForEach(GlobalShortcutAction.allCases, id: \.self) { action in
                    SettingsRow(label: action.label, hasDivider: action != .openSettings) {
                        HStack(spacing: 8) {
                            KbdBadge(shortcut: settings.shortcutDisplay(for: action))
                            StandardButton(title: recordingAction == action ? "press keys" : "record") {
                                startRecording(action)
                            }
                            DangerButton(title: "reset") {
                                reset(action)
                            }
                        }
                    }
                }
            }
            if let validationMessage {
                SettingsHint(text: validationMessage)
            } else {
                SettingsHint(text: "Click record, then press the new key combination. Use at least one modifier key.")
            }

            SectionLabel(text: "in-popover shortcuts")
            SettingsGroup {
                SettingsRow(label: "Navigate items") { KbdBadge(shortcut: "↑ ↓") }
                SettingsRow(label: "Open selected item") { KbdBadge(shortcut: "↵") }
                SettingsRow(label: "Mark selected read") { KbdBadge(shortcut: "E") }
                SettingsRow(label: "Dismiss selected") { KbdBadge(shortcut: "D") }
                SettingsRow(label: "Switch tab left / right") { KbdBadge(shortcut: "[ ]") }
                SettingsRow(label: "Close popover", hasDivider: false) { KbdBadge(shortcut: "Esc") }
            }
            SettingsHint(text: "Global shortcuts require Accessibility permission in System Settings -> Privacy & Security.")
        }
        .padding(.vertical, 20)
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording(_ action: GlobalShortcutAction) {
        stopRecording()
        recordingAction = action
        validationMessage = "Recording \(action.label.lowercased()). Press a key combination now."

        recorderMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard recordingAction == action else {
                return event
            }

            if event.keyCode == 53 {
                stopRecording()
                validationMessage = "Recording cancelled."
                return nil
            }

            guard let displayString = ShortcutRecorder.displayString(from: event),
                  GlobalShortcutDefinition.parse(action: action, displayString: displayString) != nil
            else {
                validationMessage = "Use a valid shortcut with at least one modifier key."
                return nil
            }

            settings.setShortcutDisplay(displayString, for: action)
            try? context.save()
            appState.reloadGlobalShortcuts()
            stopRecording()
            validationMessage = "\(action.label) set to \(displayString)."
            return nil
        }
    }

    private func reset(_ action: GlobalShortcutAction) {
        let defaultDefinition = GlobalShortcutDefinition.defaultDefinition(for: action)
        settings.setShortcutDisplay(defaultDefinition.displayString, for: action)
        try? context.save()
        appState.reloadGlobalShortcuts()
        validationMessage = "\(action.label) reset to \(defaultDefinition.displayString)."
    }

    private func stopRecording() {
        if let recorderMonitor {
            NSEvent.removeMonitor(recorderMonitor)
        }
        recorderMonitor = nil
        recordingAction = nil
    }
}
