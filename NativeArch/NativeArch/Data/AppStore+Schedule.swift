import Foundation

extension AppStore {
    func reloadCustomEvents() {
        customEvents = db.query("SELECT * FROM custom_events WHERE workspace_id = ? ORDER BY date", [ws]) { r in
            CustomEvent(
                id: r.string("id"),
                title: r.string("title"),
                date: r.date("date") ?? Date(),
                category: EventCategory(rawValue: r.string("category")) ?? .personal,
                note: r.string("note"),
                repeatAnnually: r.string("repeat_annually") == "1",
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveCustomEvent(_ e: CustomEvent) {
        let now = Date()
        if customEvents.contains(where: { $0.id == e.id }) {
            db.run("""
                UPDATE custom_events SET title=?, date=?, category=?, note=?,
                    repeat_annually=?, updated_at=? WHERE id=?
                """,
                [e.title, e.date, e.category.rawValue, e.note,
                 e.repeatAnnually ? 1 : 0, now, e.id])
        } else {
            db.run("""
                INSERT INTO custom_events
                    (id, created_at, updated_at, workspace_id, title, date, category,
                     note, repeat_annually)
                VALUES (?,?,?,?,?,?,?,?,?)
                """,
                [e.id, now, now, ws, e.title, e.date, e.category.rawValue, e.note,
                 e.repeatAnnually ? 1 : 0])
        }
        reloadCustomEvents()
    }

    func deleteCustomEvent(_ id: String) {
        db.run("DELETE FROM custom_events WHERE id=?", [id])
        reloadCustomEvents()
    }
}
