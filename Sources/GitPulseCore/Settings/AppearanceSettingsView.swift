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
                SettingsRow(label: "Appearance", hasDivider: false) {
                    DarkPicker(
                        options: AppAppearance.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.appearanceMode
                    )
                }
                .onChange(of: settings.appearanceMode) { _, mode in
                    applyAppearance(mode)
                }
            }

            SectionLabel(text: "popover")
            SettingsGroup {
                SettingsRow(label: "Popover width", hasDivider: false) {
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
            }
            SettingsHint(text: "Width changes apply the next time the menu bar popover opens.")
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
