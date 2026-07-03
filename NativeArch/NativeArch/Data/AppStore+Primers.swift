import Foundation

extension AppStore {
    func reloadPrimers() {
        primers = db.query("SELECT * FROM primers WHERE workspace_id = ? ORDER BY name COLLATE NOCASE", [ws]) { r in
            Primer(
                id: r.string("id"),
                name: r.string("name"),
                serialNumber: r.string("serial_number"),
                sequence: r.string("sequence"),
                targetGene: r.string("target_gene"),
                direction: r.string("direction"),
                tm: r.string("tm"),
                supplier: r.string("supplier"),
                notes: r.string("notes"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func savePrimer(_ p: Primer) {
        let now = Date()
        if primers.contains(where: { $0.id == p.id }) {
            db.run("""
                UPDATE primers SET name=?, serial_number=?, sequence=?, target_gene=?,
                    direction=?, tm=?, supplier=?, notes=?, updated_at=? WHERE id=?
                """,
                [p.name, p.serialNumber, p.sequence, p.targetGene, p.direction,
                 p.tm, p.supplier, p.notes, now, p.id])
        } else {
            db.run("""
                INSERT INTO primers
                    (id, created_at, updated_at, workspace_id, name, serial_number,
                     sequence, target_gene, direction, tm, supplier, notes)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
                """,
                [p.id, now, now, ws, p.name, p.serialNumber, p.sequence,
                 p.targetGene, p.direction, p.tm, p.supplier, p.notes])
        }
        reloadPrimers()
    }

    func deletePrimer(_ id: String) {
        db.run("DELETE FROM primers WHERE id=?", [id])
        reloadPrimers()
    }
}
