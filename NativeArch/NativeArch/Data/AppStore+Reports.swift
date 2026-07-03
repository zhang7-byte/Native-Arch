import Foundation

extension AppStore {
    func reloadReports() {
        reports = db.query("SELECT * FROM reports WHERE workspace_id = ? ORDER BY updated_at DESC", [ws]) { r in
            Report(
                id: r.string("id"),
                title: r.string("title"),
                recipient: r.string("recipient"),
                author: r.string("author"),
                periodStart: r.date("period_start"),
                periodEnd: r.date("period_end"),
                summary: r.string("summary"),
                projectIds: r.stringList("project_ids"),
                experimentIds: r.stringList("experiment_ids"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveReport(_ r: Report) {
        let now = Date()
        if reports.contains(where: { $0.id == r.id }) {
            db.run("""
                UPDATE reports SET title=?, recipient=?, author=?, period_start=?,
                    period_end=?, summary=?, project_ids=?, experiment_ids=?,
                    updated_at=? WHERE id=?
                """,
                [r.title, r.recipient, r.author, r.periodStart, r.periodEnd, r.summary,
                 encodeStringList(r.projectIds), encodeStringList(r.experimentIds), now, r.id])
        } else {
            db.run("""
                INSERT INTO reports
                    (id, created_at, updated_at, workspace_id, title, recipient, author,
                     period_start, period_end, summary, project_ids, experiment_ids)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
                """,
                [r.id, now, now, ws, r.title, r.recipient, r.author, r.periodStart,
                 r.periodEnd, r.summary, encodeStringList(r.projectIds),
                 encodeStringList(r.experimentIds)])
        }
        reloadReports()
    }

    func deleteReport(_ id: String) {
        db.run("DELETE FROM reports WHERE id=?", [id])
        reloadReports()
    }
}
