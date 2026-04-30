import SwiftData
import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case appearance
    case account
    case notifications
    case repositories
    case polling
    case menuBar
    case shortcuts
    case advanced

    var id: String { rawValue }

    var label: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .account: return "Account"
        case .notifications: return "Notifications"
        case .repositories: return "Repositories"
        case .polling: return "Polling"
        case .menuBar: return "Menu Bar"
        case .shortcuts: return "Shortcuts"
        case .advanced: return "Advanced"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "paintbrush"
        case .account: return "person.crop.circle"
        case .notifications: return "bell"
        case .repositories: return "folder"
        case .polling: return "arrow.clockwise"
        case .menuBar: return "menubar.rectangle"
        case .shortcuts: return "keyboard"
        case .advanced: return "wrench.and.screwdriver"
        }
    }
}

public struct SettingsWindowView: View {
    @State private var selection: SettingsSection? = .general

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            SettingsTitleBar()

            HStack(spacing: 0) {
                SettingsSidebar(selection: $selection)

                ScrollView {
                    detailView
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .background(GitPulseColors.background)
            }
        }
        .frame(minWidth: 700, minHeight: 520)
        .background(GitPulseColors.background)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .general {
        case .general: GeneralSettingsView()
        case .appearance: AppearanceSettingsView()
        case .account: AccountSettingsView()
        case .notifications: NotificationsSettingsView()
        case .repositories: RepositoriesSettingsView()
        case .polling: PollingSettingsView()
        case .menuBar: MenuBarSettingsView()
        case .shortcuts: ShortcutsSettingsView()
        case .advanced: AdvancedSettingsView()
        }
    }
}

private struct SettingsTitleBar: View {
    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                Circle().fill(Color(hex: 0xff5f57)).frame(width: 12, height: 12)
                Circle().fill(Color(hex: 0xffbd2e)).frame(width: 12, height: 12)
                Circle().fill(Color(hex: 0x28c840)).frame(width: 12, height: 12)
                Spacer()
            }
            .padding(.horizontal, 14)

            Text("GitPulse Settings")
                .font(GitPulseText.mono(13))
                .foregroundColor(GitPulseColors.textPrimary)
        }
        .frame(height: 38)
        .background(GitPulseColors.background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GitPulseColors.border)
                .frame(height: 0.5)
        }
    }
}

private struct SettingsSidebar: View {
    @Binding var selection: SettingsSection?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(SettingsSection.allCases) { section in
                SettingsSidebarRow(
                    section: section,
                    isActive: selection == section
                ) {
                    selection = section
                }
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .frame(width: 160)
        .background(GitPulseColors.background)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(GitPulseColors.border)
                .frame(width: 0.5)
        }
    }
}

private struct SettingsSidebarRow: View {
    let section: SettingsSection
    let isActive: Bool
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(section.iconBackground)
                    Image(systemName: section.systemImage)
                        .font(GitPulseText.mono(11))
                        .foregroundColor(section.iconColor)
                }
                .frame(width: 18, height: 18)

                Text(section.label)
                    .font(GitPulseText.mono(13, weight: isActive ? .medium : .regular))
                    .foregroundColor(isActive ? GitPulseColors.textPrimary : GitPulseColors.textSecondary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isActive ? GitPulseColors.divider : (isHovered ? GitPulseColors.rowHover : Color.clear))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

private extension SettingsSection {
    var iconBackground: Color {
        switch self {
        case .general: return Color(hex: 0xe3f0ff)
        case .appearance: return Color(hex: 0xf0e6ff)
        case .account: return Color(hex: 0xe6f5e6)
        case .notifications: return Color(hex: 0xfff3e0)
        case .repositories: return Color(hex: 0xfce8e8)
        case .polling: return Color(hex: 0xe6f0ff)
        case .menuBar: return Color(hex: 0xe8f5e9)
        case .shortcuts: return Color(hex: 0xf5f0e0)
        case .advanced: return Color(hex: 0xf0f0f0)
        }
    }

    var iconColor: Color {
        switch self {
        case .general, .polling: return GitPulseColors.blueBase
        case .appearance: return Color(hex: 0x9b59b6)
        case .account, .menuBar: return GitPulseColors.green
        case .notifications, .shortcuts: return GitPulseColors.amber
        case .repositories: return GitPulseColors.red
        case .advanced: return Color.white.opacity(0.31)
        }
    }
}
