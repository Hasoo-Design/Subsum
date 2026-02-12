import Foundation
import LocalAuthentication

@Observable
final class BiometricManager {
    static let shared = BiometricManager()

    var isUnlocked = false
    var biometricType: LABiometryType = .none

    private init() {
        checkBiometricType()
    }

    func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }

    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedReason = "Unlock Subsum"

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Subsum")
            isUnlocked = success
            return success
        } catch {
            return false
        }
    }

    var biometricName: String {
        switch biometricType {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .opticID: "Optic ID"
        default: "Biometrics"
        }
    }
}
