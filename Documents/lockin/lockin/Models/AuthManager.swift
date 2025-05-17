import Foundation
import SwiftUI
import Supabase

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var error: String?
    
    static let shared = AuthManager()
    private let client: SupabaseClient
    
    private init() {
        guard SupabaseConfig.isConfigured else {
            fatalError("Supabase configuration is missing. Please set your Supabase URL and anon key in SupabaseConfig.swift")
        }
        
        guard let url = URL(string: SupabaseConfig.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.supabaseKey
        )
        
        Task {
            await checkSession()
        }
    }
    
    struct User: Codable {
        let id: String
        let email: String
        let name: String
    }
    
    private func checkSession() async {
        do {
            let session = try await client.auth.session
            let supabaseUser = session.user
            
            if supabaseUser != nil {
                let user = User(
                    id: supabaseUser.id.uuidString,
                    email: supabaseUser.email ?? "",
                    name: supabaseUser.userMetadata["name"] as? String ?? ""
                )
                
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            }
        } catch {
            print("No active session: \(error.localizedDescription)")
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["name": AnyJSON(name)]
            )
            
            let supabaseUser = response.user
            if supabaseUser == nil {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
            }
            
            let user = User(
                id: supabaseUser.id.uuidString,
                email: supabaseUser.email ?? "",
                name: name
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            
            let supabaseUser = response.user
            if supabaseUser == nil {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in user"])
            }
            
            let user = User(
                id: supabaseUser.id.uuidString,
                email: supabaseUser.email ?? "",
                name: supabaseUser.userMetadata["name"] as? String ?? ""
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            throw error
        }
    }
    
    func signOut() async {
        do {
            try await client.auth.signOut()
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await client.auth.resetPasswordForEmail(email)
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            throw error
        }
    }
} 
