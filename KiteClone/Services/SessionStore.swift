import Foundation
import Combine

/// Holds the (dummy) authentication state for the app.
///
/// Login happens either via Face ID / Touch ID (the default), or by entering
/// any non-empty User ID + password — no server is contacted.
@MainActor
final class SessionStore: ObservableObject {

    @Published private(set) var isAuthenticated = false
    @Published private(set) var userID: String = ""

    /// Validate credentials and, on success, log in. Returns nil on success or
    /// an error string to display.
    func loginWithCredentials(userID: String, password: String) -> String? {
        let id = userID.trimmingCharacters(in: .whitespaces)
        if id.isEmpty { return "Please enter your User ID." }
        if password.isEmpty { return "Please enter your password." }
        self.userID = id.uppercased()
        isAuthenticated = true
        MarketDataService.shared.start()
        return nil
    }

    /// Complete login via a successful Face ID / Touch ID check. Uses a
    /// "remembered" user ID, mirroring Kite's biometric auto-login.
    func authenticateWithBiometrics() {
        if userID.isEmpty { userID = "ZW1607" }
        isAuthenticated = true
        MarketDataService.shared.start()
    }

    func logout() {
        MarketDataService.shared.stop()
        isAuthenticated = false
        userID = ""
    }

    /// A display name derived from the user ID, e.g. "ZU1234".
    var displayName: String {
        userID.isEmpty ? "Trader" : userID
    }
}
