import SwiftUI
import SwiftData

@main
struct PhotoSorterApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var biometricManager = BiometricAuthManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([LocalFolder.self, LocalPhoto.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(biometricManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
