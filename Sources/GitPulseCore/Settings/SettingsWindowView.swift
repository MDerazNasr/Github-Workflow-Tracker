import SwiftData
import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case account
    case polling
    case popover
    case shortcuts
    case advanced

    var id: String { rawValue }

    var label: String {
        switch self {
        case .general: return "General"
        case .account: return "Account"
        case .polling: return "Polling"
        case .popover: return "Popover"
        case .shortcuts: return "Shortcuts"
        case .advanced: return "Advanced"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape"
        case .account: return "person.crop.circle"
        case .polling: return "arrow.clockwise"
        case .popover: return "rectangle.bottomthird.inset.filled"
        case .shortcuts: return "keyboard"
        case .advanced: return "wrench.and.screwdriver"
        }
    }
}

public struct SettingsWindowView: View {
    @State private var selection: SettingsSection? = .general
    @Query private var settingsArr: [AppSettings]

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
        .preferredColorScheme(settingsArr.first?.appearance.colorScheme)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .general {
        case .general: GeneralSettingsView()
        case .account: AccountSettingsView()
        case .polling: PollingSettingsView()
        case .popover: PopoverSettingsView()
        case .shortcuts: ShortcutsSettingsView()
        case .advanced: AdvancedSettingsView()
        }
    }
}

private struct SettingsTitleBar: View {
    var body: some View {
        ZStack {
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
        case .account: return Color(hex: 0xe6f5e6)
        case .polling: return Color(hex: 0xe6f0ff)
        case .popover: return Color(hex: 0xf0e6ff)
        case .shortcuts: return Color(hex: 0xf5f0e0)
        case .advanced: return Color(hex: 0xf0f0f0)
        }
    }

    var iconColor: Color {
        switch self {
        case .general, .polling: return GitPulseColors.blueBase
        case .popover: return Color(hex: 0x9b59b6)
        case .account: return GitPulseColors.green
        case .shortcuts: return GitPulseColors.amber
        case .advanced: return GitPulseColors.mutedBadgeText
        }
    }
}
