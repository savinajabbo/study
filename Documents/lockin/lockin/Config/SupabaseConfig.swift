import Foundation

enum SupabaseConfig {
    static let supabaseURL = "https://vbvtgfqratbwugpkyzjv.supabase.co"
    static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZidnRnZnFyYXRid3VncGt5emp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0OTkyMjUsImV4cCI6MjA2MzA3NTIyNX0.F7Gpsh4XAR_0PempULCjsvdCUaGcA4uNjMtQFzIZgN8"
    
    static var isConfigured: Bool {
        return !supabaseURL.isEmpty && !supabaseKey.isEmpty
    }
} 