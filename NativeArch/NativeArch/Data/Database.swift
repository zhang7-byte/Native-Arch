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
                sqlite3_bind_int64(stmt, idx, Int64(v.timeIntervalSince1970))
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
        return Date(timeIntervalSince1970: TimeInterval(sqlite3_column_int64(stmt, i)))
    }

    func stringList(_ name: String) -> [String] {
        let raw = string(name)
        guard let data = raw.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [String] else { return [] }
        return arr
    }
}

/// JSON-encodes a string list the way drift stores it.
func encodeStringList(_ list: [String]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: list),
          let s = String(data: data, encoding: .utf8) else { return "[]" }
    return s
}
