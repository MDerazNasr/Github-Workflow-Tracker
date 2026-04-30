import SwiftData
import SwiftUI

struct PopoverQuickSettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enable notifications", isOn: $settings.notificationsEnabled)
                Toggle("Group by repository", isOn: $settings.groupNotificationsByRepo)
            }

            Section("Repositories") {
                Toggle("Only show repos with activity", isOn: $settings.showOnlyReposWithActivity)
                Toggle("Watch repos I am assigned to", isOn: $settings.watchReposImAssignedTo)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 360)
    }
}
