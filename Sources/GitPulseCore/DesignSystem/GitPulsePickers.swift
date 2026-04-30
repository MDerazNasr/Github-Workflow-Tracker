import SwiftUI

struct SelectOption<Value: Hashable>: Identifiable {
    let id: Value
    let label: String
}

struct DarkPicker<Value: Hashable>: View {
    let options: [SelectOption<Value>]
    @Binding var selection: Value

    private var selectedLabel: String {
        options.first { $0.id == selection }?.label ?? ""
    }

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button(option.label) {
                    selection = option.id
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedLabel)
                Image(systemName: "chevron.down")
                    .font(GitPulseText.mono(9))
            }
            .font(GitPulseText.mono(11))
            .foregroundColor(GitPulseColors.textRow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(minWidth: 120)
            .background(GitPulseColors.controlBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsTextInput: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(GitPulseText.mono(12))
            .foregroundColor(GitPulseColors.textRow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(focused ? GitPulseColors.hoverBorder : GitPulseColors.border, lineWidth: 0.5)
            )
            .focused($focused)
    }
}

struct SettingsSecureInput: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        SecureField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(GitPulseText.mono(12))
            .foregroundColor(GitPulseColors.textRow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(focused ? GitPulseColors.hoverBorder : GitPulseColors.border, lineWidth: 0.5)
            )
            .focused($focused)
    }
}
