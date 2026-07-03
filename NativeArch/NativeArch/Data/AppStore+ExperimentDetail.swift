import Foundation

extension AppStore {
    // MARK: - Progress log (experiment updates)

    func updates(for experimentId: String) -> [ExperimentUpdate] {
        db.query("SELECT * FROM experiment_updates WHERE experiment_id=? ORDER BY happened_at DESC",
                 [experimentId]) { r in
            ExperimentUpdate(
                id: r.string("id"),
                experimentId: r.string("experiment_id"),
                happenedAt: r.date("happened_at") ?? Date(),
                note: r.string("note"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveUpdate(_ u: ExperimentUpdate) {
        let now = Date()
        let exists = !db.query("SELECT id FROM experiment_updates WHERE id=?", [u.id]) { _ in true }.isEmpty
        if exists {
            db.run("UPDATE experiment_updates SET happened_at=?, note=?, updated_at=? WHERE id=?",
                   [u.happenedAt, u.note, now, u.id])
        } else {
            db.run("""
                INSERT INTO experiment_updates
                    (id, created_at, updated_at, workspace_id, experiment_id, happened_at, note)
                VALUES (?,?,?,?,?,?,?)
                """,
                [u.id, now, now, "", u.experimentId, u.happenedAt, u.note])
        }
    }

    func deleteUpdate(_ id: String) {
        db.run("DELETE FROM experiment_updates WHERE id=?", [id])
    }

    // MARK: - Image attachments

    func images(forExperiment experimentId: String) -> [AttachedImage] {
        db.query("SELECT * FROM images WHERE experiment_id=? ORDER BY created_at DESC",
                 [experimentId]) { r in
            AttachedImage(
                id: r.string("id"),
                experimentId: r.string("experiment_id").isEmpty ? nil : r.string("experiment_id"),
                updateId: r.string("update_id").isEmpty ? nil : r.string("update_id"),
                caption: r.string("caption"),
                notes: r.string("notes"),
                contentType: r.string("content_type"),
                createdAt: r.date("created_at") ?? Date()
            )
        }
    }

    func addImage(_ bytes: Data, experimentId: String, updateId: String? = nil,
                  contentType: String = "image/jpeg", caption: String = "") {
        let id = UUID().uuidString
        let now = Date()
        db.run("""
            INSERT INTO images
                (id, created_at, updated_at, workspace_id, experiment_id, update_id,
                 caption, content_type)
            VALUES (?,?,?,?,?,?,?,?)
            """,
            [id, now, now, "", experimentId, updateId, caption, contentType])
        db.run("INSERT INTO image_blobs (id, bytes) VALUES (?,?)", [id, bytes])
    }

    func imageBytes(_ id: String) -> Data? {
        db.query("SELECT bytes FROM image_blobs WHERE id=?", [id]) { $0.blob("bytes") }.first ?? nil
    }

    func deleteImage(_ id: String) {
        db.run("DELETE FROM images WHERE id=?", [id]) // cascade removes the blob
    }
}
