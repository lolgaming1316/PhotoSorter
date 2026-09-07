import Foundation
import Supabase

enum SupabaseManager {
    // From the "lolgaming.1316@gmail.com's Project" Supabase project
    // (Settings -> API). Rotate the anon key from the dashboard if it's
    // ever exposed publicly (e.g. committed to a public repo).
    static let projectURL = URL(string: "https://psexvtistgrtktafvguj.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzZXh2dGlzdGdydGt0YWZ2Z3VqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgzNDMxMjEsImV4cCI6MjEwMzkxOTEyMX0.izCPM6xGV4O6UABbkQJvxZvdsy5DrW3Fgr7FPEVQsgc"

    static let client = SupabaseClient(supabaseURL: projectURL, supabaseKey: anonKey)
}
