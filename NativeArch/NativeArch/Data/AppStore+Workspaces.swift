import Foundation

extension AppStore {
    private static let currentWorkspaceKey = "currentWorkspaceId"

    var currentWorkspaceId: String? {
        get { UserDefaults.standard.string(forKey: Self.currentWorkspaceKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.currentWorkspaceKey) }
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
        if currentWorkspaceId == id { currentWorkspaceId = nil }
        reloadWorkspaces()
    }
}
