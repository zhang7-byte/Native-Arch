import Foundation

extension AppStore {
    func reloadTasks() {
        tasks = db.query("SELECT * FROM tasks WHERE workspace_id = ? ORDER BY updated_at DESC", [ws]) { r in
            Task(
                id: r.string("id"),
                projectId: r.string("project_id").isEmpty ? nil : r.string("project_id"),
                experimentId: r.string("experiment_id").isEmpty ? nil : r.string("experiment_id"),
                title: r.string("title"),
                description: r.string("description"),
                dueDate: r.date("due_date"),
                status: TaskStatus(rawValue: r.string("status")) ?? .todo,
                priority: Priority(rawValue: r.string("priority")) ?? .medium,
                createdAt: r.date("created_at") ?? Date(),
                updatedAt: r.date("updated_at") ?? Date()
            )
        }
    }

    func saveTask(_ t: Task) {
        let now = Date()
        if tasks.contains(where: { $0.id == t.id }) {
            db.run("""
                UPDATE tasks SET project_id=?, experiment_id=?, title=?, description=?,
                    due_date=?, status=?, priority=?, updated_at=? WHERE id=?
                """,
                [t.projectId, t.experimentId, t.title, t.description, t.dueDate,
                 t.status.rawValue, t.priority.rawValue, now, t.id])
        } else {
            db.run("""
                INSERT INTO tasks
                    (id, created_at, updated_at, workspace_id, project_id, experiment_id,
                     title, description, due_date, status, priority)
                VALUES (?,?,?,?,?,?,?,?,?,?,?)
                """,
                [t.id, now, now, ws, t.projectId, t.experimentId, t.title,
                 t.description, t.dueDate, t.status.rawValue, t.priority.rawValue])
        }
        reloadTasks()
    }

    func deleteTask(_ id: String) {
        moveToTrash(table: "tasks", id: id, kind: "Task",
                    label: tasks.first { $0.id == id }?.title ?? "Task")
        reloadTasks()
    }
}
