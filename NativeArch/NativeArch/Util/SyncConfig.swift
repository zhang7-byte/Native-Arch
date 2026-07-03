import Foundation

/// Connection to a Supabase project (project URL + anon/public API key).
/// Persisted in UserDefaults; sync is opt-in and off until configured.
struct SyncConfig {
    var url: String = ""
    var anonKey: String = ""

    var isConfigured: Bool {
        !url.trimmingCharacters(in: .whitespaces).isEmpty &&
        !anonKey.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Normalized base URL with no trailing slash.
    var base: String { url.trimmingCharacters(in: .whitespaces).hasSuffix("/")
        ? String(url.trimmingCharacters(in: .whitespaces).dropLast())
        : url.trimmingCharacters(in: .whitespaces) }

    static let key = "syncConfig"

    static func load() -> SyncConfig {
        let d = UserDefaults.standard
        return SyncConfig(url: d.string(forKey: "\(key).url") ?? "",
                          anonKey: d.string(forKey: "\(key).anonKey") ?? "")
    }

    func save() {
        let d = UserDefaults.standard
        d.set(url, forKey: "\(Self.key).url")
        d.set(anonKey, forKey: "\(Self.key).anonKey")
    }
}

/// The signed-in session (persisted so the app stays logged in across launches).
struct AuthSession {
    var accessToken: String
    var refreshToken: String
    var userId: String
    var email: String

    static let key = "authSession"

    static func load() -> AuthSession? {
        let d = UserDefaults.standard
        guard let token = d.string(forKey: "\(key).access"), !token.isEmpty else { return nil }
        return AuthSession(
            accessToken: token,
            refreshToken: d.string(forKey: "\(key).refresh") ?? "",
            userId: d.string(forKey: "\(key).userId") ?? "",
            email: d.string(forKey: "\(key).email") ?? "")
    }

    func save() {
        let d = UserDefaults.standard
        d.set(accessToken, forKey: "\(Self.key).access")
        d.set(refreshToken, forKey: "\(Self.key).refresh")
        d.set(userId, forKey: "\(Self.key).userId")
        d.set(email, forKey: "\(Self.key).email")
    }

    static func clear() {
        let d = UserDefaults.standard
        for k in ["access", "refresh", "userId", "email"] { d.removeObject(forKey: "\(key).\(k)") }
    }
}
