import SwiftUI

struct ReagentsView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Reagent?
    @State private var creating = false
    @State private var filter = "all" // all | reagents | buffers

    private var shown: [Reagent] {
        switch filter {
        case "reagents": return store.reagents.filter { !$0.isBuffer }
        case "buffers": return store.reagents.filter { $0.isBuffer }
        default: return store.reagents
        }
    }

    var body: some View {
        List {
            ForEach(shown) { reagent in
                Button { editing = reagent } label: { ReagentRow(reagent: reagent) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteReagent(reagent.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Reagents")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Filter", selection: $filter) {
                    Text("All").tag("all")
                    Text("Reagents").tag("reagents")
                    Text("Buffers").tag("buffers")
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New reagent", systemImage: "plus") }
            }
        }
        .overlay {
            if shown.isEmpty {
                ContentUnavailableView("Nothing here yet", systemImage: "shippingbox",
                    description: Text("Tap + to add one."))
            }
        }
        .sheet(item: $editing) { ReagentEditor(reagent: $0) }
        .sheet(isPresented: $creating) {
            ReagentEditor(reagent: nil, initialKind: filter == "buffers" ? "buffer" : "reagent")
        }
    }
}

struct ReagentRow: View {
    let reagent: Reagent

    private var meta: String {
        [reagent.supplier.isEmpty ? nil : reagent.supplier,
         reagent.catalogNo.isEmpty ? nil : reagent.catalogNo,
         reagent.location.isEmpty ? nil : reagent.location]
            .compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reagent.isBuffer ? "drop.fill" : "shippingbox.fill")
                .foregroundStyle(reagent.isBuffer ? .teal : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(reagent.name).font(.headline)
                if !meta.isEmpty {
                    Text(meta).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer()
            if let exp = reagent.expiryDate {
                StatusChip(text: "exp \(exp.formatted(date: .abbreviated, time: .omitted))",
                           color: exp < Date() ? .red : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
