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
        var skipped: [String] = []
        for table in Self.syncTables {
            let rows = db.allRows(table)
            if rows.isEmpty { continue }
            let payload = rows.map { transformForPush(table: table, row: $0) }
            let result = await upsert(table: table, rows: payload, config: auth.config,
                                      token: session.accessToken)
            if result.ok { total += rows.count }
            else if Self.isMissingTable(result.message) { skipped.append(table) }
            else { return "Push failed on \(table): \(result.message)" }
        }
        return "Pushed \(total) records.\(skippedNote(skipped))"
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

    // MARK: - Pull

    /// Fetch rows changed since the last cursor, upsert locally (last-writer-wins
    /// by updated_at), and apply tombstones. Advances the cursor on success.
    func pull(using auth: AuthService) async -> String {
        guard auth.config.isConfigured, let session = auth.session else {
            return "Not signed in."
        }
        let cursor = db.meta("last_sync") ?? "1970-01-01T00:00:00Z"
        let started = Date()
        var pulled = 0
        var skipped: [String] = []
        for table in Self.syncTables {
            let (rows, err) = await fetch(table: table, config: auth.config,
                token: session.accessToken,
                query: [URLQueryItem(name: "updated_at", value: "gt.\(cursor)"),
                        URLQueryItem(name: "order", value: "updated_at.asc")])
            if let err {
                if Self.isMissingTable(err) { skipped.append(table); continue }
                return "Pull failed on \(table): \(err)"
            }
            for row in rows ?? [] {
                guard let id = row["id"] as? String else { continue }
                let local = transformFromServer(table: table, row: row)
                let serverUpd = (local["updated_at"] as? Int64) ?? 0
                let localUpd = localUpdatedAt(table, id)
                if localUpd == nil || serverUpd >= localUpd! {
                    db.upsertRow(table, local); pulled += 1
                }
            }
        }
        // Deletions.
        let (tombs, _) = await fetch(table: "tombstones", config: auth.config,
            token: session.accessToken,
            query: [URLQueryItem(name: "deleted_at", value: "gt.\(cursor)")])
        for t in tombs ?? [] {
            if let tbl = t["table_name"] as? String, let id = t["id"] as? String {
                db.run("DELETE FROM \(tbl) WHERE id=?", [id])
            }
        }
        db.setMeta("last_sync", Self.iso.string(from: started))
        await MainActor.run { reloadAll(); reloadTrash() }
        return "Pulled \(pulled) records.\(skippedNote(skipped))"
    }

    private static func isMissingTable(_ msg: String) -> Bool {
        msg.contains("PGRST205") || msg.contains("HTTP 404")
    }

    private func skippedNote(_ skipped: [String]) -> String {
        skipped.isEmpty ? "" : " Skipped (not on server): \(skipped.joined(separator: ", "))."
    }

    /// Push then pull.
    func syncNow(using auth: AuthService) async -> String {
        let p = await push(using: auth)
        if p.hasPrefix("Push failed") || p == "Not signed in." { return p }
        let q = await pull(using: auth)
        return "\(p) \(q)"
    }

    private func localUpdatedAt(_ table: String, _ id: String) -> Int64? {
        (db.query("SELECT updated_at FROM \(table) WHERE id=?", [id]) { $0.int("updated_at") }.first) ?? nil
    }

    private func transformFromServer(table: String, row: [String: Any]) -> [String: Any] {
        let dates = Self.dateColumns[table] ?? []
        let bools = Self.boolColumns[table] ?? []
        var out: [String: Any] = [:]
        for (k, v) in row {
            if dates.contains(k) {
                if let s = v as? String, let d = Self.parseISO(s) {
                    out[k] = Int64(d.timeIntervalSince1970)
                } else { out[k] = NSNull() }
            } else if bools.contains(k) {
                if let b = v as? Bool { out[k] = b ? 1 : 0 }
                else if let n = v as? Int { out[k] = n } else { out[k] = v }
            } else if let arr = v as? [Any] {          // jsonb list → JSON text
                out[k] = jsonText(arr)
            } else if let dict = v as? [String: Any] {
                out[k] = jsonText(dict)
            } else {
                out[k] = v
            }
        }
        return out
    }

    private func jsonText(_ obj: Any) -> String {
        guard let d = try? JSONSerialization.data(withJSONObject: obj),
              let s = String(data: d, encoding: .utf8) else { return "[]" }
        return s
    }

    private func fetch(table: String, config: SyncConfig, token: String,
                       query: [URLQueryItem]) async -> ([[String: Any]]?, String?) {
        guard var comps = URLComponents(string: "\(config.base)/rest/v1/\(table)") else {
            return (nil, "bad URL")
        }
        comps.queryItems = query
        guard let url = comps.url else { return (nil, "bad URL") }
        var req = URLRequest(url: url)
        req.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(code) else {
                return (nil, "HTTP \(code): \(String(decoding: data, as: UTF8.self).prefix(160))")
            }
            let arr = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] ?? []
            return (arr, nil)
        } catch {
            return (nil, error.localizedDescription)
        }
    }

    private static func parseISO(_ s: String) -> Date? {
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f1.date(from: s) { return d }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        return f2.date(from: s)
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
