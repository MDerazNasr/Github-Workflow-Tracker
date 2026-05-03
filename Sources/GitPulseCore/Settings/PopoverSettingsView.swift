import SwiftData
import SwiftUI

struct PopoverSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "popover", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Popover width", hasDivider: false) {
                    HStack(spacing: 8) {
                        Slider(
                            value: Binding(
                                get: { Double(settings.popoverWidth) },
                                set: { settings.popoverWidth = Int($0) }
                            ),
                            in: 420...560,
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
}
