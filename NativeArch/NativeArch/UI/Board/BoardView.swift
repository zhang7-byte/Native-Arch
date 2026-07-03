import SwiftUI

struct BoardView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Task?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 14) {
                ForEach(TaskStatus.allCases) { status in
                    column(status)
                }
            }
            .padding(16)
        }
        .navigationTitle("Board")
        .sheet(item: $editing) { TaskEditor(task: $0) }
    }

    private func column(_ status: TaskStatus) -> some View {
        let items = store.tasks.filter { $0.status == status }
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle().fill(Palette.color(for: status)).frame(width: 8, height: 8)
                Text(status.label).font(.headline)
                Text("\(items.count)").font(.caption).foregroundStyle(.secondary)
            }
            if items.isEmpty {
                Text("—").foregroundStyle(.secondary).font(.caption).padding(.vertical, 8)
            } else {
                ForEach(items) { task in
                    Button { editing = task } label: { card(task) }
                        .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(width: 240, alignment: .leading)
    }

    private func card(_ task: Task) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.title).font(.subheadline.weight(.medium)).lineLimit(2)
            if let pid = task.projectId, !pid.isEmpty {
                Text(store.projectTitle(pid)).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            HStack(spacing: 6) {
                StatusChip(text: task.priority.label, color: Palette.color(for: task.priority))
                if let due = task.dueDate {
                    StatusChip(text: due.formatted(date: .abbreviated, time: .omitted), color: .secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }
}
