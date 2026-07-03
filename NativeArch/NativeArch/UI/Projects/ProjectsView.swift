import SwiftUI

struct ProjectsView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Project?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.projects) { project in
                Button { editing = project } label: { ProjectRow(project: project) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.deleteProject(project.id)
                        } label: { Label("Delete", systemImage: "trash") }
                    }
            }
        }
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: {
                    Label("New project", systemImage: "plus")
                }
            }
        }
        .overlay {
            if store.projects.isEmpty {
                ContentUnavailableView("No projects yet", systemImage: "flask",
                    description: Text("Tap + to add your first project."))
            }
        }
        .sheet(item: $editing) { ProjectEditor(project: $0) }
        .sheet(isPresented: $creating) { ProjectEditor(project: nil) }
    }
}

struct ProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(project.title).font(.headline)
            if !project.description.isEmpty {
                Text(project.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            HStack(spacing: 6) {
                StatusChip(text: project.status.label, color: Palette.color(for: project.status))
                StatusChip(text: project.priority.label, color: Palette.color(for: project.priority))
                if !project.tags.isEmpty {
                    StatusChip(text: "\(project.tags.count) tag\(project.tags.count == 1 ? "" : "s")",
                               color: .secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
