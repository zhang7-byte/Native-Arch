import SwiftUI

struct DeadlinesView: View {
    @Environment(AppStore.self) private var store
    @State private var editingTask: Task?
    @State private var editingProject: Project?

    private var startOfToday: Date { Calendar.current.startOfDay(for: Date()) }

    private struct Item: Identifiable {
        let id: String
        let date: Date
        let title: String
        let kind: String        // "Task" | "Project"
        let task: Task?
        let project: Project?
    }

    private var items: [Item] {
        var out: [Item] = []
        for t in store.tasks where t.status != .done {
            if let d = t.dueDate {
                out.append(Item(id: "t-\(t.id)", date: d, title: t.title, kind: "Task",
                                task: t, project: nil))
            }
        }
        for p in store.projects {
            if let d = p.targetDate {
                out.append(Item(id: "p-\(p.id)", date: d, title: p.title, kind: "Project",
                                task: nil, project: p))
            }
        }
        return out.sorted { $0.date < $1.date }
    }

    private var overdue: [Item] { items.filter { $0.date < startOfToday } }
    private var upcoming: [Item] { items.filter { $0.date >= startOfToday } }

    var body: some View {
        List {
            if !overdue.isEmpty {
                Section("Overdue (\(overdue.count))") {
                    ForEach(overdue) { row($0, overdue: true) }
                }
            }
            Section("Upcoming (\(upcoming.count))") {
                if upcoming.isEmpty {
                    Text("Nothing upcoming.").foregroundStyle(.secondary)
                } else {
                    ForEach(upcoming) { row($0, overdue: false) }
                }
            }
        }
        .navigationTitle("Deadlines")
        .overlay {
            if items.isEmpty {
                ContentUnavailableView("No deadlines", systemImage: "calendar.badge.exclamationmark",
                    description: Text("Set due dates on tasks or target dates on projects."))
            }
        }
        .sheet(item: $editingTask) { TaskEditor(task: $0) }
        .sheet(item: $editingProject) { ProjectEditor(project: $0) }
    }

    private func row(_ item: Item, overdue: Bool) -> some View {
        Button {
            if let t = item.task { editingTask = t } else if let p = item.project { editingProject = p }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.kind == "Task" ? "checklist" : "flask")
                    .foregroundStyle(item.kind == "Task" ? .indigo : .blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title).font(.subheadline.weight(.medium)).lineLimit(1)
                    Text("\(item.kind) · \(item.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(overdue ? .red : .secondary)
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
