import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "photo.stack.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text("PhotoSorter")
                    .font(.largeTitle.bold())

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                }

                if let error = auth.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await auth.signIn(email: email, password: password) }
                } label: {
                    if auth.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Log In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty || auth.isLoading)

                Button("Create an account") {
                    showSignUp = true
                }
                .font(.footnote)

                Spacer()
                Spacer()
            }
            .padding(24)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
