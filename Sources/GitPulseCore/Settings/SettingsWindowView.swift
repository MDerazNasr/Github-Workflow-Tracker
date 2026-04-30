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
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                Label(section.label, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 160)
        } detail: {
            detailView
                .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
        }
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
