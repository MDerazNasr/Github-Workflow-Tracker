import SwiftData
import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsArr: [AppSettings]
    @Query private var prefs: [NotificationPrefs]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section("Global") {
                Toggle("Enable notifications", isOn: $settings.notificationsEnabled)
                Toggle("Respect Focus / Do Not Disturb", isOn: $settings.respectFocusMode)
                Picker("Sound", selection: $settings.notificationSound) {
                    ForEach(NotificationSoundOption.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
                Toggle("Group by repository", isOn: $settings.groupNotificationsByRepo)
            }

            Section("Event Types") {
                ForEach(EventType.allNotifiableCases) { type in
                    if let pref = pref(for: type) {
                        NotificationMatrixRow(pref: pref, label: type.displayName)
                    }
                }
            }

            Section("Quiet Hours") {
                Toggle("Enable quiet hours", isOn: $settings.quietHoursEnabled)
                if settings.quietHoursEnabled {
                    Picker("From", selection: $settings.quietHoursFrom) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(hourLabel(hour)).tag(hour)
                        }
                    }
                    Picker("To", selection: $settings.quietHoursTo) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(hourLabel(hour)).tag(hour)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            NotificationPrefs.ensureDefaults(in: context)
        }
    }

    private func pref(for type: EventType) -> NotificationPrefs? {
        prefs.first { $0.eventTypeRaw == type.rawValue }
    }

    private func hourLabel(_ hour: Int) -> String {
        let suffix = hour < 12 ? "AM" : "PM"
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        return "\(displayHour) \(suffix)"
    }
}

struct NotificationMatrixRow: View {
    @Bindable var pref: NotificationPrefs
    let label: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Toggle("Banner", isOn: $pref.banner)
                .labelsHidden()
                .help("Banner")
            Toggle("Badge", isOn: $pref.badge)
                .labelsHidden()
                .help("Badge")
            Toggle("Sound", isOn: $pref.sound)
                .labelsHidden()
                .help("Sound")
        }
    }
}
