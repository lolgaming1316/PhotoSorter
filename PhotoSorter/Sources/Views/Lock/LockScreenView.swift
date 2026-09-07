import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject var biometrics: BiometricAuthManager
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("PhotoSorter is locked")
                .font(.title2.bold())

            if let error = biometrics.lastError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Unlock with Face ID") {
                biometrics.authenticate()
            }
            .buttonStyle(.borderedProminent)

            Button("Log Out") {
                Task { await auth.signOut() }
            }
            .font(.footnote)

            Spacer()
            Spacer()
        }
        .padding()
        .onAppear { biometrics.authenticate() }
    }
}
