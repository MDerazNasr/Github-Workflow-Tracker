import AppKit
import SwiftData
import SwiftUI

struct GeneralSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "startup", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Launch at login") {
                    DarkToggle(isOn: $settings.launchAtLogin)
                }
                SettingsRow(
                    label: "Show in Dock",
                    subtitle: "Show a Dock icon in addition to the menu bar"
                ) {
                    DarkToggle(isOn: $settings.showInDock)
                }
                    .onChange(of: settings.showInDock) { _, show in
                        NSApp.setActivationPolicy(show ? .regular : .accessory)
                    }
                SettingsRow(label: "Reopen last view on launch", hasDivider: false) {
                    DarkToggle(isOn: $settings.reopenLastViewOnLaunch)
                }
            }

            SectionLabel(text: "behavior")
            SettingsGroup {
                SettingsRow(label: "Open links in") {
                    DarkPicker(
                        options: OpenLinksIn.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.openLinksIn
                    )
                }
                SettingsRow(label: "Mark as read on open") {
                    DarkToggle(isOn: $settings.markAsReadOnOpen)
                }
                SettingsRow(label: "Close popover after opening link") {
                    DarkToggle(isOn: $settings.closePopoverAfterOpeningLink)
                }
                SettingsRow(
                    label: "Group activity by repository",
                    subtitle: "Off shows a single chronological feed"
                ) {
                    DarkToggle(isOn: $settings.groupByRepo)
                }
                SettingsRow(label: "Default tab", hasDivider: false) {
                    DarkPicker(
                        options: AppDefaultTab.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.defaultTab
                    )
                }
            }

            SectionLabel(text: "data")
            SettingsGroup {
                SettingsRow(label: "Keep read items for") {
                    DarkPicker(
                        options: [
                            SelectOption(id: 1, label: "1 day"),
                            SelectOption(id: 7, label: "7 days"),
                            SelectOption(id: 30, label: "30 days"),
                            SelectOption(id: 90, label: "90 days"),
                            SelectOption(id: 0, label: "Forever")
                        ],
                        selection: $settings.retentionDaysRead
                    )
                }
                SettingsRow(label: "Keep dismissed items for") {
                    DarkPicker(
                        options: [
                            SelectOption(id: 0, label: "Never"),
                            SelectOption(id: 7, label: "7 days"),
                            SelectOption(id: 30, label: "30 days")
                        ],
                        selection: $settings.retentionDaysDismissed
                    )
                }
                SettingsRow(
                    label: "Demo mode",
                    subtitle: "Use built-in sample data, no GitHub account needed",
                    hasDivider: false
                ) {
                    DarkToggle(isOn: $settings.demoMode)
                }
            }
            SettingsHint(text: "Demo mode loads built-in sample repos and events so the app is fully navigable without an account.")
        }
        .padding(.vertical, 20)
    }
}
