import AppKit
import SwiftData
import SwiftUI

struct AppearanceSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section("Theme") {
                Picker("Appearance", selection: $settings.appearanceMode) {
                    ForEach(AppAppearance.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
                .onChange(of: settings.appearanceMode) { _, mode in
                    applyAppearance(mode)
                }
                Picker("Accent color", selection: $settings.accentColor) {
                    ForEach(AppAccentColor.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
                Toggle("Popover vibrancy", isOn: $settings.popoverVibrancy)
            }

            Section("Typography") {
                Picker("Font", selection: $settings.fontName) {
                    Text("SF Mono").tag("sf-mono")
                    Text("Menlo").tag("menlo")
                    Text("Fira Code").tag("fira-code")
                    Text("JetBrains Mono").tag("jetbrains-mono")
                    Text("Cascadia Code").tag("cascadia-code")
                }
                Slider(
                    value: Binding(
                        get: { Double(settings.fontSize) },
                        set: { settings.fontSize = Int($0) }
                    ),
                    in: 11...16,
                    step: 1
                ) {
                    Text("Font size")
                } minimumValueLabel: {
                    Text("11")
                } maximumValueLabel: {
                    Text("16")
                }
                Toggle("Dense layout", isOn: $settings.denseLayout)
            }

            Section("Popover Display") {
                Picker("Width", selection: $settings.popoverWidth) {
                    Text("300").tag(300)
                    Text("360").tag(360)
                    Text("420").tag(420)
                    Text("480").tag(480)
                }
                Picker("Maximum visible items", selection: $settings.maxVisibleItems) {
                    Text("10").tag(10)
                    Text("20").tag(20)
                    Text("30").tag(30)
                    Text("Unlimited").tag(0)
                }
                Toggle("Relative timestamps", isOn: $settings.showRelativeTimestamps)
                Toggle("Author avatars", isOn: $settings.showAuthorAvatars)
                Toggle("CI branch name", isOn: $settings.showCIBranchName)
                Toggle("Commit SHA", isOn: $settings.showCommitSHA)
            }
        }
        .formStyle(.grouped)
    }

    private func applyAppearance(_ mode: String) {
        switch AppAppearance(rawValue: mode) {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        default:
            NSApp.appearance = nil
        }
    }
}
