import SwiftUI

struct CloningView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: CloneConstruction?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.clones) { clone in
                Button { editing = clone } label: { CloneRow(clone: clone) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteClone(clone.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Cloning")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: {
                    Label("New construction", systemImage: "plus")
                }
            }
        }
        .overlay {
            if store.clones.isEmpty {
                ContentUnavailableView("No constructions yet", systemImage: "circle.hexagongrid",
                    description: Text("Tap + to design a Gibson assembly."))
            }
        }
        .sheet(item: $editing) { CloneEditor(clone: $0) }
        .sheet(isPresented: $creating) { CloneEditor(clone: nil) }
    }
}

struct CloneRow: View {
    let clone: CloneConstruction

    private var meta: String {
        [clone.backboneName.isEmpty ? nil : "Backbone: \(clone.backboneName)",
         clone.fragments.isEmpty ? nil :
            "\(clone.fragments.count) fragment\(clone.fragments.count == 1 ? "" : "s")"]
            .compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(clone.name.isEmpty ? "Untitled construction" : clone.name).font(.headline)
            if !meta.isEmpty {
                Text(meta).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
