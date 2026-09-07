import Foundation
import LocalAuthentication

@MainActor
final class BiometricAuthManager: ObservableObject {
    @Published var isUnlocked = false
    @Published var lastError: String?
    @Published var isLockEnabled: Bool {
        didSet { UserDefaults.standard.set(isLockEnabled, forKey: Self.lockEnabledKey) }
    }

    private static let lockEnabledKey = "faceIDLockEnabled"

    init() {
        // Locked by default so a fresh install behaves like a private photo vault.
        self.isLockEnabled = UserDefaults.standard.object(forKey: Self.lockEnabledKey) as? Bool ?? true
    }

    func authenticate() {
        guard isLockEnabled else {
            isUnlocked = true
            return
        }
        let context = LAContext()
        var error: NSError?
        // .deviceOwnerAuthentication falls back to passcode if Face ID fails repeatedly or isn't enrolled.
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            lastError = error?.localizedDescription ?? "Face ID / passcode is not available on this device."
            isUnlocked = false
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your private photo folders") { [weak self] success, evalError in
            Task { @MainActor in
                guard let self else { return }
                self.isUnlocked = success
                self.lastError = success ? nil : evalError?.localizedDescription
            }
        }
    }

    func lock() {
        isUnlocked = false
    }
}
