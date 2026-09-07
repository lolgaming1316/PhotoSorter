import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var infoMessage: String?

    private var passwordsMatch: Bool { !password.isEmpty && password == confirmPassword }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.title.bold())

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords do not match")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                if let infoMessage {
                    Text(infoMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await auth.signUp(email: email, password: password)
                        if auth.errorMessage == nil {
                            infoMessage = "Account created. Check your email to confirm, then log in."
                        }
                    }
                } label: {
                    if auth.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Sign Up").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || !passwordsMatch || auth.isLoading)

                Spacer()
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
