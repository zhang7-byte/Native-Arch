import SwiftUI

struct PrimersView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Primer?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.primers) { primer in
                Button { editing = primer } label: { PrimerRow(primer: primer) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deletePrimer(primer.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Primers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New primer", systemImage: "plus") }
            }
        }
        .overlay {
            if store.primers.isEmpty {
                ContentUnavailableView("No primers yet", systemImage: "waveform.path",
                    description: Text("Tap + to add one."))
            }
        }
        .sheet(item: $editing) { PrimerEditor(primer: $0) }
        .sheet(isPresented: $creating) { PrimerEditor(primer: nil) }
    }
}

struct PrimerRow: View {
    let primer: Primer

    private var meta: String {
        [primer.targetGene.isEmpty ? nil : primer.targetGene,
         primer.direction.isEmpty ? nil : primer.direction,
         primer.length > 0 ? "\(primer.length) nt" : nil]
            .compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(primer.name).font(.headline)
            if !meta.isEmpty {
                Text(meta).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
