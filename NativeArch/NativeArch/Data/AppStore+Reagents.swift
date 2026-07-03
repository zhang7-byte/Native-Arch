import Foundation

extension AppStore {
    func reloadReagents() {
        reagents = db.query("SELECT * FROM reagents ORDER BY name COLLATE NOCASE") { r in
            Reagent(
                id: r.string("id"),
                name: r.string("name"),
                kind: r.string("kind"),
                supplier: r.string("supplier"),
                catalogNo: r.string("catalog_no"),
                lot: r.string("lot"),
                location: r.string("location"),
                expiryDate: r.date("expiry_date"),
                quantity: r.string("quantity"),
                recipe: r.string("recipe"),
                notes: r.string("notes"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveReagent(_ r: Reagent) {
        let now = Date()
        if reagents.contains(where: { $0.id == r.id }) {
            db.run("""
                UPDATE reagents SET name=?, kind=?, supplier=?, catalog_no=?, lot=?,
                    location=?, expiry_date=?, quantity=?, recipe=?, notes=?,
                    updated_at=? WHERE id=?
                """,
                [r.name, r.kind, r.supplier, r.catalogNo, r.lot, r.location,
                 r.expiryDate, r.quantity, r.recipe, r.notes, now, r.id])
        } else {
            db.run("""
                INSERT INTO reagents
                    (id, created_at, updated_at, workspace_id, name, kind, supplier,
                     catalog_no, lot, location, expiry_date, quantity, recipe, notes)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                """,
                [r.id, now, now, "", r.name, r.kind, r.supplier, r.catalogNo, r.lot,
                 r.location, r.expiryDate, r.quantity, r.recipe, r.notes])
        }
        reloadReagents()
    }

    func deleteReagent(_ id: String) {
        db.run("DELETE FROM reagents WHERE id=?", [id])
        reloadReagents()
    }
}
