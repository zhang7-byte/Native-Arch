import Foundation

extension AppStore {
    func reloadCultures() {
        cultures = db.query("SELECT * FROM cultures ORDER BY started_date DESC") { r in
            Culture(
                id: r.string("id"),
                name: r.string("name"),
                strainId: r.string("strain_id").isEmpty ? nil : r.string("strain_id"),
                status: CultureStatus(rawValue: r.string("status")) ?? .active,
                medium: r.string("medium"),
                vessel: r.string("vessel"),
                startedDate: r.date("started_date") ?? Date(),
                endedDate: r.date("ended_date"),
                notes: r.string("notes"),
                purpose: r.string("purpose"),
                inoculumAmount: r.string("inoculum_amount"),
                selectionMarkers: r.stringList("selection_markers"),
                parentCultureId: r.string("parent_culture_id").isEmpty ? nil : r.string("parent_culture_id"),
                parentInoculatedAt: r.date("parent_inoculated_at"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveCulture(_ c: Culture) {
        let now = Date()
        if cultures.contains(where: { $0.id == c.id }) {
            db.run("""
                UPDATE cultures SET name=?, strain_id=?, status=?, medium=?, vessel=?,
                    started_date=?, ended_date=?, notes=?, purpose=?, inoculum_amount=?,
                    selection_markers=?, parent_culture_id=?, parent_inoculated_at=?,
                    updated_at=? WHERE id=?
                """,
                [c.name, c.strainId, c.status.rawValue, c.medium, c.vessel, c.startedDate,
                 c.endedDate, c.notes, c.purpose, c.inoculumAmount,
                 encodeStringList(c.selectionMarkers), c.parentCultureId,
                 c.parentInoculatedAt, now, c.id])
        } else {
            db.run("""
                INSERT INTO cultures
                    (id, created_at, updated_at, workspace_id, name, strain_id, status,
                     medium, vessel, started_date, ended_date, notes, purpose,
                     inoculum_amount, selection_markers, parent_culture_id,
                     parent_inoculated_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                """,
                [c.id, now, now, "", c.name, c.strainId, c.status.rawValue, c.medium,
                 c.vessel, c.startedDate, c.endedDate, c.notes, c.purpose,
                 c.inoculumAmount, encodeStringList(c.selectionMarkers),
                 c.parentCultureId, c.parentInoculatedAt])
        }
        reloadCultures()
    }

    func deleteCulture(_ id: String) {
        db.run("DELETE FROM cultures WHERE id=?", [id])
        reloadCultures()
    }

    // MARK: - Culture events (loaded on demand for a culture)

    func events(for cultureId: String) -> [CultureEvent] {
        db.query("SELECT * FROM culture_events WHERE culture_id=? ORDER BY happened_at DESC",
                 [cultureId]) { r in
            CultureEvent(
                id: r.string("id"),
                cultureId: r.string("culture_id"),
                happenedAt: r.date("happened_at") ?? Date(),
                type: CultureEventType(rawValue: r.string("type")) ?? .note,
                agent: r.string("agent"),
                amount: r.string("amount"),
                note: r.string("note"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveEvent(_ e: CultureEvent) {
        let now = Date()
        let exists = !db.query("SELECT id FROM culture_events WHERE id=?", [e.id]) { _ in true }.isEmpty
        if exists {
            db.run("""
                UPDATE culture_events SET happened_at=?, type=?, agent=?, amount=?,
                    note=?, updated_at=? WHERE id=?
                """,
                [e.happenedAt, e.type.rawValue, e.agent, e.amount, e.note, now, e.id])
        } else {
            db.run("""
                INSERT INTO culture_events
                    (id, created_at, updated_at, workspace_id, culture_id, happened_at,
                     type, agent, amount, note)
                VALUES (?,?,?,?,?,?,?,?,?,?)
                """,
                [e.id, now, now, "", e.cultureId, e.happenedAt, e.type.rawValue,
                 e.agent, e.amount, e.note])
        }
    }

    func deleteEvent(_ id: String) {
        db.run("DELETE FROM culture_events WHERE id=?", [id])
    }
}
