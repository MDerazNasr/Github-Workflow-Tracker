import SwiftData
import SwiftUI

public struct PopoverRootView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(AppState.self) private var appState
    @State private var selectedTab: PopoverTab = .activity
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
                Picker("View", selection: $selectedTab) {
                    ForEach(PopoverTab.allCases) { tab in
                        Text(tab.label).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 180)
            }

            switch selectedTab {
            case .activity:
                PopoverActivityView()
            case .settings:
                if let settings {
                    PopoverQuickSettingsView(settings: settings)
                }
            }

            Divider()

            HStack {
                Toggle("Notifications", isOn: notificationsEnabled)
                Spacer()
                Button {
                    Task {
                        await appState.refreshAuthoredPullRequests()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .disabled(appState.pullRequestSync.isRefreshing)
                .help("Refresh")

                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.borderless)
                .help("Open Full Settings")
            }
        }
        .padding(16)
        .frame(width: CGFloat(settings?.popoverWidth ?? 360))
    }
}
