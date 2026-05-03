import AppKit
import SwiftUI

struct AccountSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showTokenSheet = false
    @State private var token = ""

    var body: some View {
        let account = appState.gitHubAccount

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "connected as", isFirst: true)
            SettingsGroup {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(GitPulseColors.blueBase.opacity(0.19))
                        Circle()
                            .stroke(GitPulseColors.blueBase.opacity(0.31), lineWidth: 0.5)
                        Text(userInitials)
                            .font(GitPulseText.mono(11))
                            .foregroundColor(GitPulseColors.blue)
                    }
                    .frame(width: 30, height: 30)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(account.status.displayText)
                            .font(GitPulseText.mono(12))
                            .foregroundColor(GitPulseColors.textPrimary)
                        Text("personal access token")
                            .font(GitPulseText.mono(10))
                            .foregroundColor(GitPulseColors.textMuted)
                    }
                    Spacer()
                    StatusDot(color: account.status.isConnected ? GitPulseColors.green : GitPulseColors.red, size: 6)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                Rectangle()
                    .fill(GitPulseColors.dividerStrong)
                    .frame(height: 0.5)
                    .padding(.leading, 14)

                SettingsRow(label: "Rate limit", hasDivider: false) {
                    Text(appState.rateLimitSummary)
                        .font(GitPulseText.mono(12))
                        .foregroundColor(GitPulseColors.textSecondary)
                }
            }

            HStack(spacing: 8) {
                DangerButton(title: "Sign out") {
                    account.signOut()
                }
                StandardButton(title: connectedUser == nil ? "Connect" : "Reconnect") {
                    showTokenSheet = true
                }
                if let user = connectedUser {
                    StandardButton(title: "Open profile ↗") {
                        NSWorkspace.shared.open(user.htmlURL)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)

            if let message = account.errorMessage {
                SettingsHint(text: message)
            }

            SectionLabel(text: "personal access token")
            SettingsGroup {
                VStack(alignment: .leading, spacing: 8) {
                    SettingsSecureInput(placeholder: "ghp_xxxxxxxxxxxxxxxxxxxx", text: $token)
                    HStack(spacing: 8) {
                        StandardButton(title: "Paste token") {
                            pasteToken()
                        }
                        StandardButton(title: "Save token") {
                            Task {
                                await account.connect(token: token)
                                if account.status.isConnected {
                                    await appState.refreshAuthoredPullRequests()
                                    token = ""
                                }
                            }
                        }
                        DangerButton(title: "Clear token") {
                            token = ""
                        }
                    }
                }
                .padding(14)
            }
            SettingsHint(text: "Generate a classic PAT with scopes: repo, notifications, read:org.")
        }
        .padding(.vertical, 20)
        .background(GitPulseColors.background)
        .sheet(isPresented: $showTokenSheet) {
            TokenEntrySheet(
                token: $token,
                isConnecting: account.status == .connecting,
                onCancel: {
                    token = ""
                    showTokenSheet = false
                },
                onConnect: {
                    Task {
                        await account.connect(token: token)
                        if account.status.isConnected {
                            await appState.refreshAuthoredPullRequests()
                            token = ""
                            showTokenSheet = false
                        }
                    }
                }
            )
            .frame(width: 420)
            .padding(20)
        }
    }

    private var connectedUser: GitHubUser? {
        if case .connected(let user) = appState.gitHubAccount.status {
            return user
        }
        return nil
    }

    private var connectButtonTitle: String {
        appState.gitHubAccount.status.isConnected ? "Reconnect GitHub Account" : "Connect GitHub Account"
    }

    private var userInitials: String {
        guard let user = connectedUser else {
            return "GP"
        }
        return String(user.login.prefix(2)).uppercased()
    }

    private func pasteToken() {
        guard let pastedToken = NSPasteboard.general.string(forType: .string) else {
            return
        }
        token = pastedToken.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct TokenEntrySheet: View {
    @Binding var token: String
    @FocusState private var tokenFieldFocused: Bool
    let isConnecting: Bool
    let onCancel: () -> Void
    let onConnect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connect GitHub Account")
                .font(GitPulseText.mono(13))
                .foregroundColor(GitPulseColors.textPrimary)

            SettingsSecureInput(placeholder: "Personal access token", text: $token)
                .focused($tokenFieldFocused)

            Text("The token is verified with GitHub and stored in macOS Keychain.")
                .font(GitPulseText.mono(11))
                .foregroundColor(GitPulseColors.textSecondary)

            HStack {
                StandardButton(title: "Paste Token") {
                    pasteToken()
                }
                .disabled(isConnecting)
                Spacer()
                StandardButton(title: "Cancel", action: onCancel)
                StandardButton(title: isConnecting ? "Connecting" : "Connect") {
                    onConnect()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isConnecting || token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .background(GitPulseColors.background)
        .onAppear {
            tokenFieldFocused = true
        }
    }

    private func pasteToken() {
        guard let pastedToken = NSPasteboard.general.string(forType: .string) else {
            return
        }
        token = pastedToken.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
