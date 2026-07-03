import SwiftUI

struct TrashView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Deleted items are kept here so you can restore them. Restoring re-creates the item; items that were removed as part of a parent (e.g. an experiment's tasks) are not individually restored.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                ForEach(store.trash) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.label.isEmpty ? entry.kind : entry.label).font(.headline)
                        Text("\(entry.kind) · deleted \(entry.deletedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .swipeActions(edge: .leading) {
                        Button { store.restoreTrash(entry) } label: {
                            Label("Restore", systemImage: "arrow.uturn.backward")
                        }.tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.purgeTrash(entry.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Recently deleted")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
                ToolbarItem {
                    Button(role: .destructive) { store.emptyTrash() } label: {
                        Label("Empty", systemImage: "trash.slash")
                    }
                    .disabled(store.trash.isEmpty)
                }
            }
            .overlay {
                if store.trash.isEmpty {
                    ContentUnavailableView("Trash is empty", systemImage: "trash",
                        description: Text("Deleted items will appear here."))
                }
            }
        }
    }
}
