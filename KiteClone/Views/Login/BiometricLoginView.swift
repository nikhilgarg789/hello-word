import SwiftUI

/// The launch screen: mimics Kite's biometric auto-login. On appear it
/// automatically prompts Face ID / Touch ID and, on a match, logs the user
/// straight in. Falls back to the User ID flow if biometrics are unavailable
/// or the user chooses to.
struct BiometricLoginView: View {
    @EnvironmentObject private var session: SessionStore

    /// Called when the user wants to log in with credentials instead.
    var onUseCredentials: () -> Void

    private enum Status: Equatable {
        case idle
        case authenticating
        case failed(String)
    }

    @State private var status: Status = .idle
    @State private var pulsing = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                KiteLogo()
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 20) {
                Button(action: { Task { await authenticate() } }) {
                    Image(systemName: BiometricService.iconName)
                        .font(.system(size: 64, weight: .thin))
                        .foregroundStyle(KiteTheme.brand)
                        .scaleEffect(pulsing ? 1.08 : 1.0)
                        .opacity(status == .authenticating ? (pulsing ? 0.5 : 1) : 1)
                }
                .buttonStyle(.plain)

                Text(headline)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(KiteTheme.textPrimary)

                Text("Signed in as \(session.displayName == "Trader" ? "ZW1607" : session.displayName)")
                    .font(.system(size: 14))
                    .foregroundStyle(KiteTheme.textSecondary)

                if case .failed(let message) = status,
                   message != "cancelled", message != "fallback" {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(KiteTheme.loss)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }

            Spacer()

            VStack(spacing: 14) {
                if showsRetry {
                    Button(action: { Task { await authenticate() } }) {
                        Label("Retry \(BiometricService.displayName)", systemImage: BiometricService.iconName)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(KiteTheme.brand, in: RoundedRectangle(cornerRadius: 4))
                            .foregroundStyle(.white)
                    }
                }

                Button("Login with User ID instead", action: onUseCredentials)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(KiteTheme.buyBlue)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.white)
        .task { await runAutoLogin() }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }

    // MARK: Logic

    private var headline: String {
        switch status {
        case .authenticating: return "Authenticating…"
        case .failed(let m) where m == "cancelled" || m == "fallback":
            return "Login with \(BiometricService.displayName)"
        case .failed: return "\(BiometricService.displayName) failed"
        case .idle: return "Login with \(BiometricService.displayName)"
        }
    }

    private var showsRetry: Bool {
        if case .failed = status { return true }
        return false
    }

    /// Runs once when the screen appears — the "auto" in autologin.
    private func runAutoLogin() async {
        guard BiometricService.isAvailable else {
            // No Face ID / Touch ID set up — go straight to credentials.
            onUseCredentials()
            return
        }
        await authenticate()
    }

    private func authenticate() async {
        status = .authenticating
        let outcome = await BiometricService.authenticate()
        switch outcome {
        case .success:
            session.authenticateWithBiometrics()
        case .failure(let message):
            status = .failed(message)
        }
    }
}
