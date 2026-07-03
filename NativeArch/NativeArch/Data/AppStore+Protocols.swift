import Foundation

extension AppStore {
    func reloadProtocols() {
        protocols = db.query("SELECT * FROM protocols WHERE workspace_id = ? ORDER BY updated_at DESC", [ws]) { r in
            LabProtocol(
                id: r.string("id"),
                name: r.string("name"),
                category: r.string("category"),
                summary: r.string("summary"),
                steps: r.stringList("steps"),
                stepIds: r.stringList("step_ids"),
                materials: r.string("materials"),
                notes: r.string("notes"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveProtocol(_ p: LabProtocol) {
        let now = Date()
        if protocols.contains(where: { $0.id == p.id }) {
            db.run("""
                UPDATE protocols SET name=?, category=?, summary=?, steps=?, step_ids=?,
                    materials=?, notes=?, updated_at=? WHERE id=?
                """,
                [p.name, p.category, p.summary, encodeStringList(p.steps),
                 encodeStringList(p.stepIds), p.materials, p.notes, now, p.id])
        } else {
            db.run("""
                INSERT INTO protocols
                    (id, created_at, updated_at, workspace_id, name, category, summary,
                     steps, step_ids, materials, notes)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)
                """,
                [p.id, now, now, ws, p.name, p.category, p.summary,
                 encodeStringList(p.steps), encodeStringList(p.stepIds),
                 p.materials, p.notes])
        }
        reloadProtocols()
    }

    func deleteProtocol(_ id: String) {
        db.run("DELETE FROM protocols WHERE id=?", [id])
        reloadProtocols()
    }
}
