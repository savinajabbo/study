//
//  lockinApp.swift
//  lockin
//
//  Created by Savina Jabbo on 4/15/25.
//

import SwiftUI

@main
struct lockinApp: App {
    @StateObject private var authManager = AuthManager.shared
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ConceptListView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
