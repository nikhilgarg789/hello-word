import Foundation
import LocalAuthentication

/// Thin wrapper around `LocalAuthentication` for Face ID / Touch ID login.
enum BiometricService {

    enum Outcome {
        case success
        case failure(String)
    }

    /// The kind of biometry the device offers (populated after an availability check).
    static func biometryType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    /// Whether biometric auth can be used right now (hardware present + enrolled).
    static var isAvailable: Bool {
        var error: NSError?
        let ok = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return ok
    }

    /// Human label for the current biometry, e.g. "Face ID".
    static var displayName: String {
        switch biometryType() {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometrics"
        }
    }

    /// SF Symbol matching the current biometry.
    static var iconName: String {
        switch biometryType() {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.shield"
        }
    }

    /// Prompt the user for biometric authentication.
    static func authenticate(reason: String = "Log in to Kite") async -> Outcome {
        let context = LAContext()
        context.localizedFallbackTitle = "" // hide "Enter Password" to keep it biometric-only

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .failure("\(displayName) isn't set up on this device.")
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success ? .success : .failure("Authentication failed.")
        } catch let laError as LAError {
            switch laError.code {
            case .userCancel, .systemCancel, .appCancel:
                return .failure("cancelled")
            case .userFallback:
                return .failure("fallback")
            default:
                return .failure(laError.localizedDescription)
            }
        } catch {
            return .failure(error.localizedDescription)
        }
    }
}
