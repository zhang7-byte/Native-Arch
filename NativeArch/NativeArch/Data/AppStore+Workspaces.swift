import Foundation

extension AppStore {
    private static let currentWorkspaceKey = "currentWorkspaceId"

    var currentWorkspaceId: String? {
        get { UserDefaults.standard.string(forKey: Self.currentWorkspaceKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.currentWorkspaceKey) }
    }

    /// Ensure there is a current workspace (create a default if none), then move
    /// any pre-scoping rows (workspace_id = '') into it.
    func ensureCurrentWorkspace() {
        reloadWorkspaces()
        if workspaces.isEmpty {
            let w = Workspace(name: "My Lab")
            saveWorkspace(w)
            currentWorkspaceId = w.id
        } else if currentWorkspaceId == nil ||
                    !workspaces.contains(where: { $0.id == currentWorkspaceId }) {
            currentWorkspaceId = workspaces.first?.id
        }
        backfillWorkspace()
    }

    private func backfillWorkspace() {
        guard let id = currentWorkspaceId else { return }
        for table in ["projects", "experiments", "tasks", "strains", "reagents",
                      "primers", "protocols", "reports", "clone_constructions",
                      "cultures", "custom_events"] {
            db.run("UPDATE \(table) SET workspace_id=? WHERE workspace_id=''", [id])
        }
    }

    /// Switch the active workspace and refresh every scoped cache.
    func switchWorkspace(_ id: String) {
        currentWorkspaceId = id
        reloadAll()
    }

    func reloadWorkspaces() {
        workspaces = db.query("SELECT * FROM workspaces ORDER BY name COLLATE NOCASE") { r in
            Workspace(
                id: r.string("id"),
                name: r.string("name"),
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveWorkspace(_ w: Workspace) {
        let now = Date()
        if workspaces.contains(where: { $0.id == w.id }) {
            db.run("UPDATE workspaces SET name=?, updated_at=? WHERE id=?", [w.name, now, w.id])
        } else {
            db.run("INSERT INTO workspaces (id, created_at, updated_at, name) VALUES (?,?,?,?)",
                   [w.id, now, now, w.name])
        }
        reloadWorkspaces()
    }

    func deleteWorkspace(_ id: String) {
        db.run("DELETE FROM workspaces WHERE id=?", [id])
        reloadWorkspaces()
        if currentWorkspaceId == id {
            currentWorkspaceId = workspaces.first?.id
            reloadAll()
        }
    }
}
