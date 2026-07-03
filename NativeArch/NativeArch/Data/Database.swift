import Foundation
import SQLite3

/// A minimal, dependency-free SQLite layer using the system `SQLite3` C library.
///
/// Storage matches the Flutter/drift app for interop parity: `DateTime` is
/// stored as an INTEGER unix timestamp (seconds, UTC), string lists as JSON
/// TEXT, enums as their TEXT name, and booleans as INTEGER 0/1. Column names are
/// snake_case, exactly as drift generates them.
final class Database {
    private var db: OpaquePointer?

    /// SQLite wants this transient-destructor so it copies bound strings.
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    init() {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("NativeArch", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let path = dir.appendingPathComponent("labtrack.sqlite").path
        if sqlite3_open(path, &db) != SQLITE_OK {
            fatalError("Could not open database at \(path)")
        }
        exec("PRAGMA foreign_keys = ON;")
        createSchema()
    }

    deinit { if db != nil { sqlite3_close(db) } }

    // MARK: - Schema

    /// Phase 1 tables (Projects, Experiments). Remaining tables from the drift
    /// schema are added as each section is ported.
    private func createSchema() {
        exec("""
        CREATE TABLE IF NOT EXISTS projects (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            status TEXT NOT NULL DEFAULT 'planning',
            priority TEXT NOT NULL DEFAULT 'medium',
            start_date INTEGER,
            target_date INTEGER,
            tags TEXT NOT NULL DEFAULT '[]'
        );
        """)
        exec("""
        CREATE TABLE IF NOT EXISTS experiments (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            project_id TEXT NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            hypothesis TEXT NOT NULL DEFAULT '',
            status TEXT NOT NULL DEFAULT 'planned',
            date INTEGER,
            strain_ids TEXT NOT NULL DEFAULT '[]',
            protocol_ref TEXT NOT NULL DEFAULT '',
            methodology_steps TEXT NOT NULL DEFAULT '[]',
            results_notes TEXT NOT NULL DEFAULT '',
            conclusion TEXT NOT NULL DEFAULT '',
            further_plan TEXT NOT NULL DEFAULT '',
            data_links TEXT NOT NULL DEFAULT '[]'
        );
        """)
        exec("CREATE INDEX IF NOT EXISTS idx_experiments_project ON experiments (project_id);")

        exec("""
        CREATE TABLE IF NOT EXISTS tasks (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            project_id TEXT REFERENCES projects (id) ON DELETE CASCADE,
            experiment_id TEXT REFERENCES experiments (id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            due_date INTEGER,
            status TEXT NOT NULL DEFAULT 'todo',
            priority TEXT NOT NULL DEFAULT 'medium'
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS strains (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            name TEXT NOT NULL,
            serial_number TEXT NOT NULL DEFAULT '',
            host_organism TEXT NOT NULL DEFAULT '',
            genotype TEXT NOT NULL DEFAULT '',
            plasmid TEXT NOT NULL DEFAULT '',
            construct_notes TEXT NOT NULL DEFAULT '',
            selection_markers TEXT NOT NULL DEFAULT '[]',
            freezer_location TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT ''
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS reagents (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            name TEXT NOT NULL,
            kind TEXT NOT NULL DEFAULT 'reagent',
            supplier TEXT NOT NULL DEFAULT '',
            catalog_no TEXT NOT NULL DEFAULT '',
            lot TEXT NOT NULL DEFAULT '',
            location TEXT NOT NULL DEFAULT '',
            expiry_date INTEGER,
            quantity TEXT NOT NULL DEFAULT '',
            recipe TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT ''
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS primers (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            name TEXT NOT NULL,
            serial_number TEXT NOT NULL DEFAULT '',
            sequence TEXT NOT NULL DEFAULT '',
            target_gene TEXT NOT NULL DEFAULT '',
            direction TEXT NOT NULL DEFAULT '',
            tm TEXT NOT NULL DEFAULT '',
            supplier TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT ''
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS protocols (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            name TEXT NOT NULL,
            category TEXT NOT NULL DEFAULT '',
            summary TEXT NOT NULL DEFAULT '',
            steps TEXT NOT NULL DEFAULT '[]',
            step_ids TEXT NOT NULL DEFAULT '[]',
            materials TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT ''
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS reports (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            title TEXT NOT NULL DEFAULT 'Progress report',
            recipient TEXT NOT NULL DEFAULT '',
            author TEXT NOT NULL DEFAULT '',
            period_start INTEGER,
            period_end INTEGER,
            summary TEXT NOT NULL DEFAULT '',
            project_ids TEXT NOT NULL DEFAULT '[]',
            experiment_ids TEXT NOT NULL DEFAULT '[]'
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS clone_constructions (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            name TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT '',
            backbone_name TEXT NOT NULL DEFAULT '',
            backbone_strain_id TEXT NOT NULL DEFAULT '',
            enzymes TEXT NOT NULL DEFAULT '',
            fragments TEXT NOT NULL DEFAULT '[]'
        );
        """)

        // Manuscripts: no native UI yet, but the table exists so cloud snapshots
        // round-trip it without data loss.
        exec("""
        CREATE TABLE IF NOT EXISTS manuscripts (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            project_id TEXT REFERENCES projects (id) ON DELETE CASCADE,
            title TEXT NOT NULL DEFAULT '',
            target_journal TEXT NOT NULL DEFAULT '',
            status TEXT NOT NULL DEFAULT 'drafting',
            submission_id TEXT NOT NULL DEFAULT '',
            submitted_date INTEGER,
            notes TEXT NOT NULL DEFAULT ''
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS cultures (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            name TEXT NOT NULL DEFAULT '',
            strain_id TEXT REFERENCES strains (id) ON DELETE SET NULL,
            status TEXT NOT NULL DEFAULT 'active',
            medium TEXT NOT NULL DEFAULT '',
            vessel TEXT NOT NULL DEFAULT '',
            started_date INTEGER NOT NULL,
            ended_date INTEGER,
            notes TEXT NOT NULL DEFAULT '',
            purpose TEXT NOT NULL DEFAULT '',
            inoculum_amount TEXT NOT NULL DEFAULT '',
            selection_markers TEXT NOT NULL DEFAULT '[]',
            parent_culture_id TEXT,
            parent_inoculated_at INTEGER
        );
        """)
        exec("CREATE INDEX IF NOT EXISTS idx_cultures_status ON cultures (status);")

        exec("""
        CREATE TABLE IF NOT EXISTS culture_events (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            culture_id TEXT NOT NULL REFERENCES cultures (id) ON DELETE CASCADE,
            happened_at INTEGER NOT NULL,
            type TEXT NOT NULL DEFAULT 'note',
            agent TEXT NOT NULL DEFAULT '',
            amount TEXT NOT NULL DEFAULT '',
            note TEXT NOT NULL DEFAULT ''
        );
        """)
        exec("CREATE INDEX IF NOT EXISTS idx_culture_events_culture ON culture_events (culture_id);")

        exec("""
        CREATE TABLE IF NOT EXISTS custom_events (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            title TEXT NOT NULL,
            date INTEGER NOT NULL,
            category TEXT NOT NULL DEFAULT 'personal',
            note TEXT NOT NULL DEFAULT '',
            repeat_annually INTEGER NOT NULL DEFAULT 0
        );
        """)
        exec("CREATE INDEX IF NOT EXISTS idx_custom_events_date ON custom_events (date);")

        exec("""
        CREATE TABLE IF NOT EXISTS app_settings (
            id INTEGER NOT NULL PRIMARY KEY DEFAULT 0,
            theme_mode TEXT NOT NULL DEFAULT 'system',
            accent_color INTEGER NOT NULL DEFAULT 4278290603,
            density TEXT NOT NULL DEFAULT 'comfortable',
            notify_frequency TEXT NOT NULL DEFAULT 'daily',
            holiday_region TEXT NOT NULL DEFAULT 'none',
            schedule_notify INTEGER NOT NULL DEFAULT 1,
            updated_at INTEGER NOT NULL DEFAULT 0
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS workspaces (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            name TEXT NOT NULL DEFAULT 'My Lab'
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS experiment_updates (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            experiment_id TEXT NOT NULL REFERENCES experiments (id) ON DELETE CASCADE,
            happened_at INTEGER NOT NULL,
            note TEXT NOT NULL DEFAULT ''
        );
        """)
        exec("CREATE INDEX IF NOT EXISTS idx_updates_experiment ON experiment_updates (experiment_id);")

        exec("""
        CREATE TABLE IF NOT EXISTS images (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            experiment_id TEXT REFERENCES experiments (id) ON DELETE CASCADE,
            strain_id TEXT REFERENCES strains (id) ON DELETE CASCADE,
            culture_id TEXT REFERENCES cultures (id) ON DELETE CASCADE,
            update_id TEXT REFERENCES experiment_updates (id) ON DELETE CASCADE,
            report_id TEXT REFERENCES reports (id) ON DELETE CASCADE,
            protocol_id TEXT REFERENCES protocols (id) ON DELETE CASCADE,
            step_id TEXT,
            caption TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT '',
            annotations TEXT NOT NULL DEFAULT '[]',
            content_type TEXT NOT NULL DEFAULT 'image/jpeg',
            storage_path TEXT NOT NULL DEFAULT ''
        );
        """)
        exec("CREATE INDEX IF NOT EXISTS idx_images_experiment ON images (experiment_id);")

        exec("""
        CREATE TABLE IF NOT EXISTS image_blobs (
            id TEXT NOT NULL PRIMARY KEY REFERENCES images (id) ON DELETE CASCADE,
            bytes BLOB NOT NULL
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS trash_entries (
            id TEXT NOT NULL PRIMARY KEY,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            workspace_id TEXT NOT NULL DEFAULT '',
            entity_table TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            kind TEXT NOT NULL DEFAULT '',
            label TEXT NOT NULL DEFAULT '',
            deleted_at INTEGER NOT NULL,
            payload TEXT NOT NULL
        );
        """)

        exec("""
        CREATE TABLE IF NOT EXISTS sync_meta (
            key TEXT NOT NULL PRIMARY KEY,
            value TEXT NOT NULL DEFAULT ''
        );
        """)
    }

    /// key/value read + write for sync bookkeeping (e.g. the last-sync cursor).
    func meta(_ key: String) -> String? {
        query("SELECT value FROM sync_meta WHERE key=?", [key]) { $0.string("value") }.first
    }

    func setMeta(_ key: String, _ value: String) {
        run("INSERT INTO sync_meta (key, value) VALUES (?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",
            [key, value])
    }

    /// Upsert a typed dictionary (used when applying pulled rows).
    func upsertRow(_ table: String, _ obj: [String: Any]) {
        let cols = Array(obj.keys)
        guard !cols.isEmpty else { return }
        let colList = cols.joined(separator: ",")
        let placeholders = cols.map { _ in "?" }.joined(separator: ",")
        let params: [Any?] = cols.map { key in
            let v = obj[key]
            if v is NSNull { return nil }
            if let n = v as? Int { return n }
            if let n = v as? Int64 { return Int(n) }
            if let d = v as? Double { return d }
            if let b = v as? Bool { return b ? 1 : 0 }
            return v as? String
        }
        run("INSERT OR REPLACE INTO \(table) (\(colList)) VALUES (\(placeholders))", params)
    }

    // MARK: - Generic row capture / restore (for Trash)

    /// Serialize a single row to a JSON object (column → typed value).
    func rowJSON(_ table: String, id: String) -> String? {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, "SELECT * FROM \(table) WHERE id=?", -1, &stmt, nil) == SQLITE_OK
        else { return nil }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        var obj: [String: Any] = [:]
        for i in 0..<sqlite3_column_count(stmt) {
            let name = String(cString: sqlite3_column_name(stmt, i))
            switch sqlite3_column_type(stmt, i) {
            case SQLITE_INTEGER: obj[name] = sqlite3_column_int64(stmt, i)
            case SQLITE_FLOAT: obj[name] = sqlite3_column_double(stmt, i)
            case SQLITE_NULL: obj[name] = NSNull()
            default:
                if let c = sqlite3_column_text(stmt, i) { obj[name] = String(cString: c) }
            }
        }
        guard let data = try? JSONSerialization.data(withJSONObject: obj) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// All rows of a table as typed dictionaries (Int64 / Double / String / NSNull).
    func allRows(_ table: String) -> [[String: Any]] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, "SELECT * FROM \(table)", -1, &stmt, nil) == SQLITE_OK
        else { return [] }
        defer { sqlite3_finalize(stmt) }
        var out: [[String: Any]] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            var obj: [String: Any] = [:]
            for i in 0..<sqlite3_column_count(stmt) {
                let name = String(cString: sqlite3_column_name(stmt, i))
                switch sqlite3_column_type(stmt, i) {
                case SQLITE_INTEGER: obj[name] = sqlite3_column_int64(stmt, i)
                case SQLITE_FLOAT: obj[name] = sqlite3_column_double(stmt, i)
                case SQLITE_NULL: obj[name] = NSNull()
                default:
                    if let c = sqlite3_column_text(stmt, i) { obj[name] = String(cString: c) }
                }
            }
            out.append(obj)
        }
        return out
    }

    /// Re-insert a row captured by [rowJSON].
    func insertRow(_ table: String, json: String) {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        let cols = Array(obj.keys)
        let colList = cols.joined(separator: ",")
        let placeholders = cols.map { _ in "?" }.joined(separator: ",")
        let params: [Any?] = cols.map { key in
            let v = obj[key]
            if v is NSNull { return nil }
            if let n = v as? Int { return n }
            if let n = v as? Int64 { return Int(n) }
            if let d = v as? Double { return d }
            return v as? String
        }
        run("INSERT OR REPLACE INTO \(table) (\(colList)) VALUES (\(placeholders))", params)
    }

    // MARK: - Low-level helpers

    /// Runs one or more statements with no result rows.
    func exec(_ sql: String) {
        var err: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK, let err {
            print("SQLite exec error: \(String(cString: err)) — for: \(sql)")
            sqlite3_free(err)
        }
    }

    /// Runs a query, mapping each row via [map]. `params` are bound in order and
    /// may be String, Int, Double, Date, or nil.
    func query<T>(_ sql: String, _ params: [Any?] = [], map: (Row) -> T) -> [T] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("SQLite prepare error: \(String(cString: sqlite3_errmsg(db)))")
            return []
        }
        defer { sqlite3_finalize(stmt) }
        bind(stmt, params)
        var out: [T] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            out.append(map(Row(stmt: stmt!)))
        }
        return out
    }

    /// Runs an INSERT/UPDATE/DELETE with ordered parameters.
    func run(_ sql: String, _ params: [Any?] = []) {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            print("SQLite prepare error: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        defer { sqlite3_finalize(stmt) }
        bind(stmt, params)
        if sqlite3_step(stmt) != SQLITE_DONE {
            print("SQLite step error: \(String(cString: sqlite3_errmsg(db)))")
        }
    }

    private func bind(_ stmt: OpaquePointer?, _ params: [Any?]) {
        for (i, p) in params.enumerated() {
            let idx = Int32(i + 1)
            switch p {
            case nil:
                sqlite3_bind_null(stmt, idx)
            case let v as String:
                sqlite3_bind_text(stmt, idx, v, -1, SQLITE_TRANSIENT)
            case let v as Int:
                sqlite3_bind_int64(stmt, idx, Int64(v))
            case let v as Double:
                sqlite3_bind_double(stmt, idx, v)
            case let v as Date:
                // Match the Flutter/drift store (storeDateTimeAsText): ISO-8601.
                sqlite3_bind_text(stmt, idx, DriftDate.string(v), -1, SQLITE_TRANSIENT)
            case let v as Data:
                v.withUnsafeBytes { raw in
                    sqlite3_bind_blob(stmt, idx, raw.baseAddress, Int32(v.count), SQLITE_TRANSIENT)
                }
            default:
                sqlite3_bind_text(stmt, idx, "\(p!)", -1, SQLITE_TRANSIENT)
            }
        }
    }
}

/// Typed column access for one result row.
struct Row {
    let stmt: OpaquePointer

    private func index(_ name: String) -> Int32? {
        let count = sqlite3_column_count(stmt)
        for i in 0..<count where String(cString: sqlite3_column_name(stmt, i)) == name {
            return i
        }
        return nil
    }

    func string(_ name: String) -> String {
        guard let i = index(name), let c = sqlite3_column_text(stmt, i) else { return "" }
        return String(cString: c)
    }

    func date(_ name: String) -> Date? {
        guard let i = index(name), sqlite3_column_type(stmt, i) != SQLITE_NULL else { return nil }
        // Dates are ISO-8601 text (drift storeDateTimeAsText). Fall back to a
        // legacy integer-seconds value if any old row still holds one.
        if let c = sqlite3_column_text(stmt, i) {
            let s = String(cString: c)
            if let d = DriftDate.parse(s) { return d }
            if let secs = Int64(s) { return Date(timeIntervalSince1970: TimeInterval(secs)) }
        }
        return nil
    }

    func int(_ name: String) -> Int64? {
        guard let i = index(name), sqlite3_column_type(stmt, i) != SQLITE_NULL else { return nil }
        return sqlite3_column_int64(stmt, i)
    }

    func blob(_ name: String) -> Data? {
        guard let i = index(name), sqlite3_column_type(stmt, i) != SQLITE_NULL,
              let ptr = sqlite3_column_blob(stmt, i) else { return nil }
        let count = Int(sqlite3_column_bytes(stmt, i))
        return Data(bytes: ptr, count: count)
    }

    func stringList(_ name: String) -> [String] {
        let raw = string(name)
        guard let data = raw.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [String] else { return [] }
        return arr
    }
}

/// ISO-8601 date text compatible with the Flutter/drift `storeDateTimeAsText`
/// format (UTC, 'T' separator, fractional seconds, trailing 'Z'). Reading is
/// lenient to also accept space-separated and non-fractional variants.
enum DriftDate {
    private static let writer: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func string(_ date: Date) -> String { writer.string(from: date) }

    static func parse(_ s: String) -> Date? {
        let iso1 = ISO8601DateFormatter()
        iso1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso1.date(from: s) { return d }
        let iso2 = ISO8601DateFormatter()
        iso2.formatOptions = [.withInternetDateTime]
        if let d = iso2.date(from: s) { return d }
        // Space-separated / microsecond variants drift may emit.
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd HH:mm:ss.SSSSSS",
                    "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"] {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(identifier: "UTC")
            df.dateFormat = fmt
            if let d = df.date(from: s) { return d }
        }
        return nil
    }
}

/// JSON-encodes a string list the way drift stores it.
func encodeStringList(_ list: [String]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: list),
          let s = String(data: data, encoding: .utf8) else { return "[]" }
    return s
}
