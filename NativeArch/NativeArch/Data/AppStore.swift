import Foundation
import Observation

/// App-wide observable state: owns the database and the in-memory caches the
/// SwiftUI views bind to. Mutations write through to SQLite and refresh the
/// relevant cache (ordered newest-first, matching the Flutter app).
@Observable
final class AppStore {
    let db = Database()

    private(set) var projects: [Project] = []
    private(set) var experiments: [Experiment] = []
    // Settable across files so the per-section repository extensions can refresh.
    var tasks: [Task] = []
    var strains: [Strain] = []
    var reagents: [Reagent] = []

    init() {
        reloadProjects()
        reloadExperiments()
        reloadTasks()
        reloadStrains()
        reloadReagents()
    }

    // MARK: - Projects

    func reloadProjects() {
        projects = db.query(
            "SELECT * FROM projects ORDER BY updated_at DESC"
        ) { r in
            Project(
                id: r.string("id"),
                title: r.string("title"),
                description: r.string("description"),
                status: ProjectStatus(rawValue: r.string("status")) ?? .planning,
                priority: Priority(rawValue: r.string("priority")) ?? .medium,
                startDate: r.date("start_date"),
                targetDate: r.date("target_date"),
                tags: r.stringList("tags"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveProject(_ p: Project) {
        let now = Date()
        if projects.contains(where: { $0.id == p.id }) {
            db.run("""
                UPDATE projects SET title=?, description=?, status=?, priority=?,
                    start_date=?, target_date=?, tags=?, updated_at=? WHERE id=?
                """,
                [p.title, p.description, p.status.rawValue, p.priority.rawValue,
                 p.startDate, p.targetDate, encodeStringList(p.tags), now, p.id])
        } else {
            db.run("""
                INSERT INTO projects
                    (id, created_at, updated_at, workspace_id, title, description,
                     status, priority, start_date, target_date, tags)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)
                """,
                [p.id, now, now, "", p.title, p.description, p.status.rawValue,
                 p.priority.rawValue, p.startDate, p.targetDate, encodeStringList(p.tags)])
        }
        reloadProjects()
    }

    func deleteProject(_ id: String) {
        db.run("DELETE FROM projects WHERE id=?", [id])
        reloadProjects()
        reloadExperiments() // cascade removed the project's experiments
    }

    func projectTitle(_ id: String) -> String {
        projects.first { $0.id == id }?.title ?? "—"
    }

    // MARK: - Experiments

    func reloadExperiments() {
        experiments = db.query(
            "SELECT * FROM experiments ORDER BY updated_at DESC"
        ) { r in
            Experiment(
                id: r.string("id"),
                projectId: r.string("project_id"),
                title: r.string("title"),
                hypothesis: r.string("hypothesis"),
                status: ExperimentStatus(rawValue: r.string("status")) ?? .planned,
                date: r.date("date"),
                strainIds: r.stringList("strain_ids"),
                protocolRef: r.string("protocol_ref"),
                methodologySteps: r.stringList("methodology_steps"),
                resultsNotes: r.string("results_notes"),
                conclusion: r.string("conclusion"),
                furtherPlan: r.string("further_plan"),
                dataLinks: r.stringList("data_links"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveExperiment(_ e: Experiment) {
        let now = Date()
        if experiments.contains(where: { $0.id == e.id }) {
            db.run("""
                UPDATE experiments SET project_id=?, title=?, hypothesis=?, status=?,
                    date=?, strain_ids=?, protocol_ref=?, methodology_steps=?,
                    results_notes=?, conclusion=?, further_plan=?, data_links=?,
                    updated_at=? WHERE id=?
                """,
                [e.projectId, e.title, e.hypothesis, e.status.rawValue, e.date,
                 encodeStringList(e.strainIds), e.protocolRef,
                 encodeStringList(e.methodologySteps), e.resultsNotes, e.conclusion,
                 e.furtherPlan, encodeStringList(e.dataLinks), now, e.id])
        } else {
            db.run("""
                INSERT INTO experiments
                    (id, created_at, updated_at, workspace_id, project_id, title,
                     hypothesis, status, date, strain_ids, protocol_ref,
                     methodology_steps, results_notes, conclusion, further_plan, data_links)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                """,
                [e.id, now, now, "", e.projectId, e.title, e.hypothesis,
                 e.status.rawValue, e.date, encodeStringList(e.strainIds),
                 e.protocolRef, encodeStringList(e.methodologySteps), e.resultsNotes,
                 e.conclusion, e.furtherPlan, encodeStringList(e.dataLinks)])
        }
        reloadExperiments()
    }

    func deleteExperiment(_ id: String) {
        db.run("DELETE FROM experiments WHERE id=?", [id])
        reloadExperiments()
    }
}
