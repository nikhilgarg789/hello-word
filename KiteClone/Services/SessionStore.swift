import Foundation
import Combine

/// Holds the (dummy) authentication state for the app.
///
/// Any non-empty User ID + password is accepted, followed by any 6-digit PIN —
/// this mirrors Kite's two-step login without contacting a real server.
final class SessionStore: ObservableObject {

    @Published private(set) var isAuthenticated = false
    @Published private(set) var userID: String = ""

    /// Step 1: validate credentials. Returns nil on success or an error string.
    func validateCredentials(userID: String, password: String) -> String? {
        let id = userID.trimmingCharacters(in: .whitespaces)
        if id.isEmpty { return "Please enter your User ID." }
        if password.isEmpty { return "Please enter your password." }
        self.userID = id.uppercased()
        return nil
    }

    /// Step 2: validate the PIN and complete login.
    func validatePIN(_ pin: String) -> String? {
        guard pin.count == 6, pin.allSatisfy(\.isNumber) else {
            return "Enter your 6-digit PIN."
        }
        isAuthenticated = true
        MarketDataService.shared.start()
        return nil
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
