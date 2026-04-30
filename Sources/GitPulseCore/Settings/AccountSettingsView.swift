import AppKit
import SwiftUI

struct AccountSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showTokenSheet = false
    @State private var token = ""

    var body: some View {
        let account = appState.gitHubAccount

        Form {
            Section("GitHub") {
                LabeledContent("Status", value: account.status.displayText)
                if let user = connectedUser {
                    Link("Open \(user.login) on GitHub", destination: user.htmlURL)
                }
                Button(connectButtonTitle) {
                    showTokenSheet = true
                }
                .disabled(account.status == .connecting)
                Button("Sign Out", role: .destructive) {
                    account.signOut()
                }
                    .disabled(!account.status.isConnected)
                if let message = account.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }

            Section("Token") {
                Text("Use a GitHub personal access token with access to the repositories you want GitPulse to track.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
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
                .font(.headline)

            SecureField("Personal access token", text: $token)
                .textFieldStyle(.roundedBorder)
                .focused($tokenFieldFocused)

            Text("The token is verified with GitHub and stored in macOS Keychain.")
                .foregroundStyle(.secondary)

            HStack {
                Button("Paste Token") {
                    pasteToken()
                }
                .disabled(isConnecting)
                Spacer()
                Button("Cancel", action: onCancel)
                    .disabled(isConnecting)
                Button {
                    onConnect()
                } label: {
                    if isConnecting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Connect")
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isConnecting || token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
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
