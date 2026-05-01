import AppKit
import SwiftData
import SwiftUI

public struct PopoverRootView: View {
    @Environment(AppState.self) private var appState
    @State private var activeFilter: FeedFilter = .all
    @Query private var settingsArr: [AppSettings]

    public init() {}

    private var settings: AppSettings? {
        settingsArr.first
    }

    public var body: some View {
        if let settings {
            content(settings: settings)
        } else {
            content(settings: nil)
        }
    }

    private func content(settings: AppSettings?) -> some View {
        VStack(spacing: 0) {
            PopoverHeader(
                isRefreshing: appState.pullRequestSync.isRefreshing,
                markAllRead: {
                    appState.lastMarkedAllReadDate = Date()
                },
                refresh: {
                    Task {
                        await appState.refreshAuthoredPullRequests()
                    }
                }
            )

            HStack(spacing: 6) {
                ForEach(FeedFilter.allCases) { filter in
                    FilterPill(label: filter.label, isActive: activeFilter == filter) {
                        activeFilter = filter
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 0.5)
            }

            PopoverActivityView(activeFilter: activeFilter)

            PopoverFooter(
                appVersion: appVersion,
                openSettings: { appState.showSettingsWindow() },
                openGitHub: { openGitHubProfile() }
            )
        }
        .background(GitPulseColors.background)
        .frame(
            width: CGFloat(max(settings?.popoverWidth ?? 420, 420)),
            height: 640,
            alignment: .top
        )
        .background(GitPulseColors.background)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10))
        .overlay(
            UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
                .stroke(GitPulseColors.border, lineWidth: 0.5)
        )
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }

    private func openGitHubProfile() {
        if case .connected(let user) = appState.gitHubAccount.status {
            NSWorkspace.shared.open(user.htmlURL)
        } else if let url = URL(string: "https://github.com") {
            NSWorkspace.shared.open(url)
        }
    }
}
