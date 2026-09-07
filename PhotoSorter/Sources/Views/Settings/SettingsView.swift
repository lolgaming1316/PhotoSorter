import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var biometrics: BiometricAuthManager

    var body: some View {
        Form {
            Section("Account") {
                if let email = auth.userEmail {
                    LabeledContent("Email", value: email)
                }
                Button("Log Out", role: .destructive) {
                    Task { await auth.signOut() }
                }
            }

            Section("Security") {
                Toggle("Lock with Face ID", isOn: $biometrics.isLockEnabled)
            }
        }
        .navigationTitle("Settings")
    }
}
