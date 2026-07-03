import Foundation

extension AppStore {
    func reloadStrains() {
        strains = db.query("SELECT * FROM strains WHERE workspace_id = ? ORDER BY name COLLATE NOCASE", [ws]) { r in
            Strain(
                id: r.string("id"),
                name: r.string("name"),
                serialNumber: r.string("serial_number"),
                hostOrganism: r.string("host_organism"),
                genotype: r.string("genotype"),
                plasmid: r.string("plasmid"),
                constructNotes: r.string("construct_notes"),
                selectionMarkers: r.stringList("selection_markers"),
                freezerLocation: r.string("freezer_location"),
                notes: r.string("notes"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveStrain(_ s: Strain) {
        let now = Date()
        if strains.contains(where: { $0.id == s.id }) {
            db.run("""
                UPDATE strains SET name=?, serial_number=?, host_organism=?, genotype=?,
                    plasmid=?, construct_notes=?, selection_markers=?, freezer_location=?,
                    notes=?, updated_at=? WHERE id=?
                """,
                [s.name, s.serialNumber, s.hostOrganism, s.genotype, s.plasmid,
                 s.constructNotes, encodeStringList(s.selectionMarkers),
                 s.freezerLocation, s.notes, now, s.id])
        } else {
            db.run("""
                INSERT INTO strains
                    (id, created_at, updated_at, workspace_id, name, serial_number,
                     host_organism, genotype, plasmid, construct_notes,
                     selection_markers, freezer_location, notes)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
                """,
                [s.id, now, now, ws, s.name, s.serialNumber, s.hostOrganism,
                 s.genotype, s.plasmid, s.constructNotes,
                 encodeStringList(s.selectionMarkers), s.freezerLocation, s.notes])
        }
        reloadStrains()
    }

    func deleteStrain(_ id: String) {
        moveToTrash(table: "strains", id: id, kind: "Strain",
                    label: strains.first { $0.id == id }?.name ?? "Strain")
        reloadStrains()
    }
}
