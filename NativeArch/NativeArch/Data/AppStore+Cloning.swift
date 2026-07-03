import Foundation

extension AppStore {
    func reloadClones() {
        clones = db.query("SELECT * FROM clone_constructions WHERE workspace_id = ? ORDER BY updated_at DESC", [ws]) { r in
            CloneConstruction(
                id: r.string("id"),
                name: r.string("name"),
                notes: r.string("notes"),
                backboneName: r.string("backbone_name"),
                backboneStrainId: r.string("backbone_strain_id"),
                enzymes: r.string("enzymes"),
                fragments: decodeFragments(r.string("fragments")),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveClone(_ c: CloneConstruction) {
        let now = Date()
        if clones.contains(where: { $0.id == c.id }) {
            db.run("""
                UPDATE clone_constructions SET name=?, notes=?, backbone_name=?,
                    backbone_strain_id=?, enzymes=?, fragments=?, updated_at=? WHERE id=?
                """,
                [c.name, c.notes, c.backboneName, c.backboneStrainId, c.enzymes,
                 encodeFragments(c.fragments), now, c.id])
        } else {
            db.run("""
                INSERT INTO clone_constructions
                    (id, created_at, updated_at, workspace_id, name, notes,
                     backbone_name, backbone_strain_id, enzymes, fragments)
                VALUES (?,?,?,?,?,?,?,?,?,?)
                """,
                [c.id, now, now, ws, c.name, c.notes, c.backboneName,
                 c.backboneStrainId, c.enzymes, encodeFragments(c.fragments)])
        }
        reloadClones()
    }

    func deleteClone(_ id: String) {
        moveToTrash(table: "clone_constructions", id: id, kind: "Construction",
                    label: clones.first { $0.id == id }?.name ?? "Construction")
        reloadClones()
    }
}
