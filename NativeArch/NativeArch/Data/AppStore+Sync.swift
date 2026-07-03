import Foundation

extension AppStore {
    /// Tables that sync to Postgres (entity + child tables). Local-only tables
    /// (image_blobs, trash_entries, app_settings, workspaces) are excluded.
    static let syncTables = [
        "projects", "experiments", "tasks", "strains", "reagents", "primers",
        "protocols", "reports", "clone_constructions", "cultures", "custom_events",
        "culture_events", "experiment_updates", "images",
    ]

    /// INTEGER (unix-seconds) columns that map to Postgres timestamptz.
    static let dateColumns: [String: Set<String>] = [
        "projects": ["created_at", "updated_at", "start_date", "target_date"],
        "experiments": ["created_at", "updated_at", "date"],
        "tasks": ["created_at", "updated_at", "due_date"],
        "strains": ["created_at", "updated_at"],
        "reagents": ["created_at", "updated_at", "expiry_date"],
        "primers": ["created_at", "updated_at"],
        "protocols": ["created_at", "updated_at"],
        "reports": ["created_at", "updated_at", "period_start", "period_end"],
        "clone_constructions": ["created_at", "updated_at"],
        "cultures": ["created_at", "updated_at", "started_date", "ended_date", "parent_inoculated_at"],
        "custom_events": ["created_at", "updated_at", "date"],
        "culture_events": ["created_at", "updated_at", "happened_at"],
        "experiment_updates": ["created_at", "updated_at", "happened_at"],
        "images": ["created_at", "updated_at"],
    ]

    static let boolColumns: [String: Set<String>] = [
        "custom_events": ["repeat_annually"],
    ]

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; return f
    }()

    /// Upload all local rows to Supabase (PostgREST upsert on the primary key,
    /// last-writer-wins by updated_at server-side). Returns a status string.
    func push(using auth: AuthService) async -> String {
        guard auth.config.isConfigured, let session = auth.session else {
            return "Not signed in."
        }
        var total = 0
        for table in Self.syncTables {
            let rows = db.allRows(table)
            if rows.isEmpty { continue }
            let payload = rows.map { transformForPush(table: table, row: $0) }
            let result = await upsert(table: table, rows: payload, config: auth.config,
                                      token: session.accessToken)
            if result.ok { total += rows.count }
            else { return "Push failed on \(table): \(result.message)" }
        }
        return "Pushed \(total) records."
    }

    private func transformForPush(table: String, row: [String: Any]) -> [String: Any] {
        let dates = Self.dateColumns[table] ?? []
        let bools = Self.boolColumns[table] ?? []
        var out: [String: Any] = [:]
        for (k, v) in row {
            if dates.contains(k), let secs = v as? Int64 {
                out[k] = Self.iso.string(from: Date(timeIntervalSince1970: TimeInterval(secs)))
            } else if bools.contains(k), let n = v as? Int64 {
                out[k] = (n != 0)
            } else {
                out[k] = v
            }
        }
        return out
    }

    private func upsert(table: String, rows: [[String: Any]], config: SyncConfig,
                        token: String) async -> (ok: Bool, message: String) {
        guard let url = URL(string: "\(config.base)/rest/v1/\(table)") else {
            return (false, "bad URL")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        req.httpBody = try? JSONSerialization.data(withJSONObject: rows)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(code) { return (true, "") }
            let body = String(decoding: data, as: UTF8.self)
            return (false, "HTTP \(code): \(body.prefix(160))")
        } catch {
            return (false, error.localizedDescription)
        }
    }
}
