import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var biometrics: BiometricAuthManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if !auth.isAuthenticated {
                LoginView()
            } else if biometrics.isLockEnabled && !biometrics.isUnlocked {
                LockScreenView()
            } else {
                MainTabView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                biometrics.lock()
            } else if newPhase == .active && auth.isAuthenticated {
                biometrics.authenticate()
            }
        }
        .onAppear {
            if auth.isAuthenticated {
                biometrics.authenticate()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                FolderListView()
            }
            .tabItem { Label("Folders", systemImage: "folder.fill") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
