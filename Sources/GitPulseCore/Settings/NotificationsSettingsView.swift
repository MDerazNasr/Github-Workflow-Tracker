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

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "global controls", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Enable notifications") {
                    DarkToggle(isOn: $settings.notificationsEnabled)
                }
                SettingsRow(
                    label: "Respect Focus / Do Not Disturb",
                    subtitle: "Suppress banners when a Focus mode is active"
                ) {
                    DarkToggle(isOn: $settings.respectFocusMode)
                }
                SettingsRow(label: "Notification sound") {
                    DarkPicker(
                        options: NotificationSoundOption.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.notificationSound
                    )
                }
                SettingsRow(label: "Group notifications by repo", hasDivider: false) {
                    DarkToggle(isOn: $settings.groupNotificationsByRepo)
                }
            }

            SectionLabel(text: "notification types")
            SettingsGroup {
                HStack {
                    Text("event")
                        .font(GitPulseText.mono(10))
                        .foregroundColor(GitPulseColors.textFaint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("banner").frame(width: 48)
                    Text("badge").frame(width: 48)
                    Text("sound").frame(width: 48)
                }
                .font(GitPulseText.mono(10))
                .foregroundColor(GitPulseColors.textFaint)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.02))

                ForEach(EventType.allNotifiableCases) { type in
                    if let pref = pref(for: type) {
                        NotificationMatrixRow(pref: pref, label: type.displayName)
                    }
                }
            }

            SectionLabel(text: "quiet hours")
            SettingsGroup {
                SettingsRow(
                    label: "Enable quiet hours",
                    subtitle: "Suppress all banners and sounds during this window",
                    hasDivider: settings.quietHoursEnabled
                ) {
                    DarkToggle(isOn: $settings.quietHoursEnabled)
                }
                if settings.quietHoursEnabled {
                    SettingsRow(label: "From") {
                        DarkPicker(
                            options: (0..<24).map { SelectOption(id: $0, label: hourLabel($0)) },
                            selection: $settings.quietHoursFrom
                        )
                    }
                    SettingsRow(label: "To", hasDivider: false) {
                        DarkPicker(
                            options: (0..<24).map { SelectOption(id: $0, label: hourLabel($0)) },
                            selection: $settings.quietHoursTo
                        )
                    }
                }
            }
        }
        .padding(.vertical, 20)
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
                .font(GitPulseText.mono(11))
                .foregroundColor(GitPulseColors.textRow)
            Spacer()
            MiniToggle(isOn: $pref.banner).frame(width: 48)
            MiniToggle(isOn: $pref.badge).frame(width: 48)
            MiniToggle(isOn: $pref.sound).frame(width: 48)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }
}
