import SwiftUI

struct NotificationsSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "status", isFirst: true)
            SettingsGroup {
                SettingsRow(
                    label: "Notification delivery",
                    subtitle: "The current build refreshes pull requests in the popover only",
                    hasDivider: false
                ) {
                    CountBadge(text: "not enabled", tone: .gray)
                }
            }
            SettingsHint(text: "Notification toggles were removed until a delivery service is implemented.")
        }
        .padding(.vertical, 20)
    }
}
