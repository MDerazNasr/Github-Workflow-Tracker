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

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "theme", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Appearance") {
                    DarkPicker(
                        options: AppAppearance.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.appearanceMode
                    )
                }
                .onChange(of: settings.appearanceMode) { _, mode in
                    applyAppearance(mode)
                }
                SettingsRow(label: "Accent color") {
                    DarkPicker(
                        options: AppAccentColor.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.accentColor
                    )
                }
                SettingsRow(
                    label: "Popover vibrancy",
                    subtitle: "Blur and tint the popover background",
                    hasDivider: false
                ) {
                    DarkToggle(isOn: $settings.popoverVibrancy)
                }
            }

            SectionLabel(text: "typography")
            SettingsGroup {
                SettingsRow(label: "Font") {
                    DarkPicker(
                        options: [
                            SelectOption(id: "sf-mono", label: "SF Mono"),
                            SelectOption(id: "menlo", label: "Menlo"),
                            SelectOption(id: "fira-code", label: "Fira Code"),
                            SelectOption(id: "jetbrains-mono", label: "JetBrains Mono")
                        ],
                        selection: $settings.fontName
                    )
                }
                SettingsRow(label: "Font size") {
                    HStack(spacing: 8) {
                        Slider(
                            value: Binding(
                                get: { Double(settings.fontSize) },
                                set: { settings.fontSize = Int($0) }
                            ),
                            in: 11...16,
                            step: 1
                        )
                        .frame(width: 100)
                        .tint(GitPulseColors.green)
                        Text("\(settings.fontSize)pt")
                            .font(GitPulseText.mono(12))
                            .foregroundColor(GitPulseColors.textRow)
                            .frame(width: 32, alignment: .trailing)
                    }
                }
                SettingsRow(
                    label: "Dense layout",
                    subtitle: "Reduce padding to show more items without scrolling",
                    hasDivider: false
                ) {
                    DarkToggle(isOn: $settings.denseLayout)
                }
            }

            SectionLabel(text: "popover")
            SettingsGroup {
                SettingsRow(label: "Popover width") {
                    HStack(spacing: 8) {
                        Slider(
                            value: Binding(
                                get: { Double(settings.popoverWidth) },
                                set: { settings.popoverWidth = Int($0) }
                            ),
                            in: 300...480,
                            step: 10
                        )
                        .frame(width: 100)
                        .tint(GitPulseColors.green)
                        Text("\(settings.popoverWidth)pt")
                            .font(GitPulseText.mono(12))
                            .foregroundColor(GitPulseColors.textRow)
                            .frame(width: 44, alignment: .trailing)
                    }
                }
                SettingsRow(label: "Max visible items") {
                    DarkPicker(
                        options: [
                            SelectOption(id: 10, label: "10"),
                            SelectOption(id: 20, label: "20"),
                            SelectOption(id: 30, label: "30"),
                            SelectOption(id: 0, label: "Unlimited")
                        ],
                        selection: $settings.maxVisibleItems
                    )
                }
                SettingsRow(label: "Show relative timestamps", subtitle: "Off shows exact date and time") {
                    DarkToggle(isOn: $settings.showRelativeTimestamps)
                }
                SettingsRow(label: "Show author avatars") {
                    DarkToggle(isOn: $settings.showAuthorAvatars)
                }
                SettingsRow(label: "Show CI branch name") {
                    DarkToggle(isOn: $settings.showCIBranchName)
                }
                SettingsRow(label: "Show commit SHA on CI rows", hasDivider: false) {
                    DarkToggle(isOn: $settings.showCommitSHA)
                }
            }
        }
        .padding(.vertical, 20)
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
