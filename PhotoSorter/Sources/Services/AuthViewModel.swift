import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var listenerTask: Task<Void, Never>?

    init() {
        listenerTask = Task { [weak self] in
            for await (_, session) in await SupabaseManager.client.auth.authStateChanges {
                guard let self else { return }
                self.isAuthenticated = session != nil
                self.userEmail = session?.user.email
            }
        }
    }

    deinit {
        listenerTask?.cancel()
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await SupabaseManager.client.auth.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await SupabaseManager.client.auth.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        try? await SupabaseManager.client.auth.signOut()
    }

    /// Used to tag locally-stored folders/photos with the signed-in user.
    var currentUserId: String {
        SupabaseManager.client.auth.currentSession?.user.id.uuidString ?? "local-user"
    }
}
