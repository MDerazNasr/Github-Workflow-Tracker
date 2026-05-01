import SwiftUI

struct MenuBarSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "status item", isFirst: true)
            SettingsGroup {
                SettingsRow(
                    label: "Menu bar control",
                    subtitle: "The GitPulse icon opens the pull request popover",
                    hasDivider: false
                ) {
                    CountBadge(text: "active", tone: .green)
                }
            }
            SettingsHint(text: "Icon style, badge count, and tab toggles were removed until they control real status item behavior.")
        }
        .padding(.vertical, 20)
    }
}
