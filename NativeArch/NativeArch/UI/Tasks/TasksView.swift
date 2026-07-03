import SwiftUI

struct TasksView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Task?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.tasks) { task in
                Button { editing = task } label: { TaskRow(task: task) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteTask(task.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New task", systemImage: "plus") }
            }
        }
        .overlay {
            if store.tasks.isEmpty {
                ContentUnavailableView("No tasks yet", systemImage: "checklist",
                    description: Text("Tap + to add one."))
            }
        }
        .sheet(item: $editing) { TaskEditor(task: $0) }
        .sheet(isPresented: $creating) { TaskEditor(task: nil) }
    }
}

struct TaskRow: View {
    @Environment(AppStore.self) private var store
    let task: Task

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.title).font(.headline)
            if let pid = task.projectId, !pid.isEmpty {
                Text("in \(store.projectTitle(pid))")
                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
            HStack(spacing: 6) {
                StatusChip(text: task.status.label, color: Palette.color(for: task.status))
                StatusChip(text: task.priority.label, color: Palette.color(for: task.priority))
                if let due = task.dueDate {
                    StatusChip(text: due.formatted(date: .abbreviated, time: .omitted),
                               color: .secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
