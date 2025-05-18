import SwiftUI

@main
struct lockinApp: App {
    @StateObject private var authManager = AuthManager.shared
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
