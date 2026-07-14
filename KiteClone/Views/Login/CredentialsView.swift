import SwiftUI
import UIKit

/// Step 1 of login: User ID + password, styled like Kite's login screen.
struct CredentialsView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var userID = ""
    @State private var password = ""
    @State private var error: String?
    @FocusState private var focused: Field?

    private enum Field: Hashable { case userID, password }

    var onUseBiometrics: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                KiteLogo()
                    .padding(.top, 56)
                    .padding(.bottom, 4)

                Text("Login to Kite")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(KiteTheme.textPrimary)

                VStack(spacing: 18) {
                    LabeledField(
                        title: "Phone or User ID",
                        text: $userID,
                        placeholder: "e.g. ZU1234",
                        keyboard: .asciiCapable,
                        focus: $focused,
                        field: .userID
                    )
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .onSubmit { focused = .password }

                    LabeledField(
                        title: "Password",
                        text: $password,
                        placeholder: "••••••",
                        isSecure: true,
                        focus: $focused,
                        field: .password
                    )
                    .submitLabel(.go)
                    .onSubmit(attemptLogin)
                }
                .padding(.top, 8)

                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(KiteTheme.loss)
                }

                Button(action: attemptLogin) {
                    HStack {
                        Text("Login")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 18)
                    .background(KiteTheme.brand, in: RoundedRectangle(cornerRadius: 4))
                    .foregroundStyle(.white)
                }
                .padding(.top, 8)

                Button("Forgot user ID or password?") { }
                    .font(.system(size: 14))
                    .foregroundStyle(KiteTheme.buyBlue)

                if BiometricService.isAvailable {
                    Button(action: onUseBiometrics) {
                        Label("Login with \(BiometricService.displayName)",
                              systemImage: BiometricService.iconName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(KiteTheme.textPrimary)
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 60)

                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundStyle(KiteTheme.textSecondary)
                        Text("Signup now!")
                            .foregroundStyle(KiteTheme.buyBlue)
                    }
                    .font(.system(size: 13))
                    Text("Demo build — enter any User ID and password.")
                        .font(.system(size: 12))
                        .foregroundStyle(KiteTheme.textSecondary)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear { focused = .userID }
    }

    private func attemptLogin() {
        if let message = session.loginWithCredentials(userID: userID, password: password) {
            error = message
        } else {
            error = nil
        }
    }
}

/// A titled underlined input field, matching Kite's form fields. The underline
/// highlights in the brand color while the field is focused.
struct LabeledField<F: Hashable>: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var focus: FocusState<F?>.Binding
    var field: F

    private var isFocused: Bool { focus.wrappedValue.map { $0 == field } ?? false }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(KiteTheme.textSecondary)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused(focus, equals: field)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                        .focused(focus, equals: field)
                }
            }
            .font(.system(size: 17))
            .padding(.vertical, 8)
            Rectangle()
                .fill(isFocused ? KiteTheme.brand : KiteTheme.separator)
                .frame(height: isFocused ? 1.5 : 1)
        }
    }
}
