import Foundation

extension AppStore {
    func reloadTrash() {
        trash = db.query(
            "SELECT * FROM trash_entries WHERE workspace_id = ? ORDER BY deleted_at DESC", [ws]
        ) { r in
            TrashEntry(
                id: r.string("id"),
                entityTable: r.string("entity_table"),
                entityId: r.string("entity_id"),
                kind: r.string("kind"),
                label: r.string("label"),
                deletedAt: r.date("deleted_at") ?? Date(),
                payload: r.string("payload")
            )
        }
    }

    /// Capture a row to the Trash, then hard-delete it (cascade removes children).
    /// Restoring re-creates the captured top-level row.
    func moveToTrash(table: String, id: String, kind: String, label: String) {
        guard let payload = db.rowJSON(table, id: id) else {
            db.run("DELETE FROM \(table) WHERE id=?", [id]); return
        }
        let now = Date()
        db.run("""
            INSERT INTO trash_entries
                (id, created_at, updated_at, workspace_id, entity_table, entity_id,
                 kind, label, deleted_at, payload)
            VALUES (?,?,?,?,?,?,?,?,?,?)
            """,
            [UUID().uuidString, now, now, ws, table, id, kind, label, now, payload])
        db.run("DELETE FROM \(table) WHERE id=?", [id])
        reloadTrash()
    }

    func restoreTrash(_ entry: TrashEntry) {
        db.insertRow(entry.entityTable, json: entry.payload)
        db.run("DELETE FROM trash_entries WHERE id=?", [entry.id])
        reloadAll()
        reloadTrash()
    }

    func purgeTrash(_ id: String) {
        db.run("DELETE FROM trash_entries WHERE id=?", [id])
        reloadTrash()
    }

    func emptyTrash() {
        db.run("DELETE FROM trash_entries WHERE workspace_id=?", [ws])
        reloadTrash()
    }
}
