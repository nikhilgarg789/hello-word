import SwiftUI
import UIKit

/// Step 1 of login: User ID + password. Any non-empty values are accepted.
struct CredentialsView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var userID = ""
    @State private var password = ""
    @State private var error: String?
    @FocusState private var focused: Field?

    private enum Field { case userID, password }

    /// Called when credentials pass validation.
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                KiteLogo()
                    .padding(.top, 40)

                Text("Login to Kite")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(KiteTheme.textPrimary)

                VStack(spacing: 16) {
                    LabeledField(
                        title: "User ID",
                        text: $userID,
                        placeholder: "e.g. ZU1234",
                        keyboard: .asciiCapable
                    )
                    .focused($focused, equals: .userID)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .onSubmit { focused = .password }

                    LabeledField(
                        title: "Password",
                        text: $password,
                        placeholder: "Password",
                        isSecure: true
                    )
                    .focused($focused, equals: .password)
                    .submitLabel(.go)
                    .onSubmit(attemptLogin)
                }

                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(KiteTheme.loss)
                }

                Button(action: attemptLogin) {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(KiteTheme.brand, in: RoundedRectangle(cornerRadius: 6))
                        .foregroundStyle(.white)
                }
                .padding(.top, 4)

                Button("Forgot user ID or password?") { }
                    .font(.subheadline)
                    .foregroundStyle(KiteTheme.buyBlue)

                Spacer(minLength: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Don't have an account? Signup now!")
                        .foregroundStyle(KiteTheme.buyBlue)
                    Text("Demo build — enter any User ID and password to continue.")
                        .foregroundStyle(KiteTheme.textSecondary)
                }
                .font(.footnote)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear { focused = .userID }
    }

    private func attemptLogin() {
        if let message = session.validateCredentials(userID: userID, password: password) {
            error = message
        } else {
            error = nil
            onContinue()
        }
    }
}

/// A titled input field styled like Kite's underlined form fields.
struct LabeledField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(KiteTheme.textSecondary)
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                }
            }
            .font(.body)
            .padding(.vertical, 10)
            Rectangle()
                .fill(KiteTheme.separator)
                .frame(height: 1)
        }
    }
}
