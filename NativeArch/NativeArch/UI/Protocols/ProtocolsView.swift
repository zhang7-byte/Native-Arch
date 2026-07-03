import SwiftUI

struct ProtocolsView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: LabProtocol?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.protocols) { proto in
                Button { editing = proto } label: { ProtocolRow(proto: proto) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteProtocol(proto.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Protocols")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New protocol", systemImage: "plus") }
            }
        }
        .overlay {
            if store.protocols.isEmpty {
                ContentUnavailableView("No protocols yet", systemImage: "book",
                    description: Text("Tap + to add one."))
            }
        }
        .sheet(item: $editing) { ProtocolEditor(proto: $0) }
        .sheet(isPresented: $creating) { ProtocolEditor(proto: nil) }
    }
}

struct ProtocolRow: View {
    let proto: LabProtocol

    private var meta: String {
        [proto.category.isEmpty ? nil : proto.category,
         proto.steps.isEmpty ? nil : "\(proto.steps.count) step\(proto.steps.count == 1 ? "" : "s")"]
            .compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(proto.name).font(.headline)
            if !meta.isEmpty {
                Text(meta).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
