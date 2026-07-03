import SwiftUI

struct ExperimentsView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Experiment?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.experiments) { exp in
                Button { editing = exp } label: { ExperimentRow(experiment: exp) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.deleteExperiment(exp.id)
                        } label: { Label("Delete", systemImage: "trash") }
                    }
            }
        }
        .navigationTitle("Experiments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: {
                    Label("New experiment", systemImage: "plus")
                }
                .disabled(store.projects.isEmpty)
            }
        }
        .overlay {
            if store.experiments.isEmpty {
                ContentUnavailableView(
                    store.projects.isEmpty ? "Create a project first" : "No experiments yet",
                    systemImage: "testtube.2",
                    description: Text(store.projects.isEmpty
                        ? "Every experiment belongs to a project."
                        : "Tap + to add one."))
            }
        }
        .sheet(item: $editing) { ExperimentEditor(experiment: $0) }
        .sheet(isPresented: $creating) { ExperimentEditor(experiment: nil) }
    }
}

struct ExperimentRow: View {
    @Environment(AppStore.self) private var store
    let experiment: Experiment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(experiment.title).font(.headline)
            Text("in \(store.projectTitle(experiment.projectId))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: 6) {
                StatusChip(text: experiment.status.label,
                           color: Palette.color(for: experiment.status))
                if !experiment.strainIds.isEmpty {
                    StatusChip(text: "\(experiment.strainIds.count) strain(s)", color: .secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
