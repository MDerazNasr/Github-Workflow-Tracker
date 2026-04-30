import SwiftUI

struct AccountSettingsView: View {
    var body: some View {
        Form {
            Section("GitHub") {
                LabeledContent("Status", value: "Not connected")
                Button("Connect GitHub Account") {}
                Button("Sign Out", role: .destructive) {}
                    .disabled(true)
            }

            Section("Token") {
                Text("Account credentials will be stored in Keychain by the GitHub account service.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
