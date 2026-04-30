import SwiftData
import SwiftUI

public struct PopoverRootView: View {
    @Environment(\.openSettings) private var openSettings
    @Query private var settingsArr: [AppSettings]

    public init() {}

    private var settings: AppSettings? {
        settingsArr.first
    }

    public var body: some View {
        if let settings {
            @Bindable var settings = settings

            content(settings: settings, notificationsEnabled: $settings.notificationsEnabled)
        } else {
            content(settings: nil, notificationsEnabled: .constant(true))
        }
    }

    private func content(settings: AppSettings?, notificationsEnabled: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("GitPulse")
                    .font(.headline)
                Spacer()
                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.borderless)
                .help("Open Settings")
            }

            Text("No activity yet")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 120)

            Divider()

            Toggle(
                "Notifications",
                isOn: notificationsEnabled
            )
        }
        .padding(16)
        .frame(width: CGFloat(settings?.popoverWidth ?? 360))
    }
}
