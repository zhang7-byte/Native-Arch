import Foundation
import Observation

/// Supabase auth (GoTrue) over URLSession — no third-party SDK.
@Observable
final class AuthService {
    var config: SyncConfig
    var session: AuthSession?
    var lastError: String?
    var busy = false

    init() {
        config = SyncConfig.load()
        session = AuthSession.load()
    }

    var isSignedIn: Bool { session != nil }
    var email: String { session?.email ?? "" }

    func saveConfig(_ c: SyncConfig) { config = c; c.save() }

    func signIn(email: String, password: String) async {
        await authenticate(path: "/auth/v1/token?grant_type=password",
                           body: ["email": email, "password": password])
    }

    func signUp(email: String, password: String) async {
        await authenticate(path: "/auth/v1/signup",
                           body: ["email": email, "password": password])
    }

    func signOut() {
        session = nil
        AuthSession.clear()
    }

    @MainActor
    private func authenticate(path: String, body: [String: String]) async {
        guard config.isConfigured else { lastError = "Set the Supabase URL and key first."; return }
        busy = true; lastError = nil
        defer { busy = false }
        guard let url = URL(string: config.base + path) else { lastError = "Invalid URL."; return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(code) else {
                lastError = (json["msg"] ?? json["error_description"] ?? json["message"]
                             ?? "Sign-in failed (\(code))") as? String ?? "Sign-in failed (\(code))"
                return
            }
            guard let access = json["access_token"] as? String else {
                // Sign-up with email confirmation returns no session.
                lastError = "Check your email to confirm the account, then sign in."
                return
            }
            let userObj = json["user"] as? [String: Any]
            let s = AuthSession(
                accessToken: access,
                refreshToken: json["refresh_token"] as? String ?? "",
                userId: userObj?["id"] as? String ?? "",
                email: userObj?["email"] as? String ?? body["email"] ?? "")
            s.save()
            session = s
        } catch {
            lastError = error.localizedDescription
        }
    }
}
