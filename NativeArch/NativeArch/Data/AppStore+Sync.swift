import Foundation

extension AppStore {
    /// Whole-database snapshot tables, matching the Flutter app's `sync_snapshots`
    /// contract (parents before children). Device-local tables (sync_meta,
    /// tombstones, trash_entries, app_settings) are intentionally excluded.
    static let snapshotTables = [
        "workspaces", "projects", "strains", "reagents", "primers", "reports",
        "protocols", "clone_constructions", "experiments", "manuscripts", "tasks",
        "cultures", "experiment_updates", "custom_events", "culture_events", "images",
    ]

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; return f
    }()

    // MARK: - Push (upload this device's snapshot, overwriting the cloud copy)

    func push(using auth: AuthService) async -> String {
        guard auth.config.isConfigured, let session = auth.session else { return "Not signed in." }

        // Build the snapshot dict (raw column values; dates are unix-seconds ints,
        // lists are JSON text — exactly how the Flutter/drift store holds them).
        var snap: [String: Any] = ["version": 1]
        var rowCount = 0
        for table in Self.snapshotTables {
            let rows = db.allRows(table)
            snap[table] = rows
            rowCount += rows.count
        }
        var blobs: [String: String] = [:]
        for r in db.query("SELECT id, bytes FROM image_blobs", []) { row -> (String, Data?) in
            (row.string("id"), row.blob("bytes"))
        } where r.1 != nil {
            blobs[r.0] = r.1!.base64EncodedString()
        }
        snap["image_blobs"] = blobs

        guard let json = try? JSONSerialization.data(withJSONObject: snap) else {
            return "Failed to encode snapshot."
        }
        // Upload plain JSON (the Flutter decoder accepts un-gzipped payloads).
        let payload = json.base64EncodedString()
        let now = Self.iso.string(from: Date())
        let body: [String: Any] = [
            "user_id": session.userId, "payload": payload,
            "data_version": now, "updated_at": now,
        ]
        guard let url = URL(string: "\(auth.config.base)/rest/v1/sync_snapshots?on_conflict=user_id") else {
            return "Bad URL."
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(auth.config.anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        req.httpBody = try? JSONSerialization.data(withJSONObject: [body])
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(code) else {
                return "Push failed (HTTP \(code)): \(String(decoding: data, as: UTF8.self).prefix(180))"
            }
            return "Pushed \(rowCount) records to the cloud."
        } catch {
            return "Push failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Pull (download the cloud snapshot, replacing local data)

    func pull(using auth: AuthService) async -> String {
        guard auth.config.isConfigured, let session = auth.session else { return "Not signed in." }
        guard let url = URL(string:
            "\(auth.config.base)/rest/v1/sync_snapshots?user_id=eq.\(session.userId)&select=payload") else {
            return "Bad URL."
        }
        var req = URLRequest(url: url)
        req.setValue(auth.config.anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            guard (200..<300).contains(code) else {
                return "Pull failed (HTTP \(code)): \(String(decoding: data, as: UTF8.self).prefix(180))"
            }
            let rows = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] ?? []
            guard let payload = rows.first?["payload"] as? String else {
                return "Nothing in the cloud yet — push from a device first."
            }
            guard let raw = Data(base64Encoded: payload) else { return "Corrupt payload." }
            let jsonData = Gzip.isGzip(raw) ? (Gzip.gunzip(raw) ?? raw) : raw
            guard let snap = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] else {
                return "Could not decode the cloud snapshot."
            }
            let applied = applySnapshot(snap)
            await MainActor.run {
                ensureCurrentWorkspace(); reloadAll(); reloadTrash(); refreshNotifications()
            }
            return "Pulled \(applied) records from the cloud."
        } catch {
            return "Pull failed: \(error.localizedDescription)"
        }
    }

    /// Replace all local snapshot tables + image blobs with the snapshot.
    private func applySnapshot(_ snap: [String: Any]) -> Int {
        var applied = 0
        db.run("BEGIN", [])
        db.exec("PRAGMA defer_foreign_keys = ON;")
        for table in Self.snapshotTables {
            db.run("DELETE FROM \(table)", [])
            let rows = (snap[table] as? [[String: Any]]) ?? []
            for row in rows { db.upsertRow(table, row); applied += 1 }
        }
        db.run("DELETE FROM image_blobs", [])
        if let blobs = snap["image_blobs"] as? [String: String] {
            for (id, b64) in blobs {
                if let bytes = Data(base64Encoded: b64) {
                    db.run("INSERT OR REPLACE INTO image_blobs (id, bytes) VALUES (?,?)", [id, bytes])
                }
            }
        }
        db.run("COMMIT", [])
        return applied
    }
}
