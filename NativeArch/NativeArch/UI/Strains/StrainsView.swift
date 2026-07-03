import SwiftUI

struct StrainsView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Strain?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.strains) { strain in
                Button { editing = strain } label: { StrainRow(strain: strain) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteStrain(strain.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Strains")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New strain", systemImage: "plus") }
            }
        }
        .overlay {
            if store.strains.isEmpty {
                ContentUnavailableView("No strains yet", systemImage: "allergens",
                    description: Text("Tap + to add one."))
            }
        }
        .sheet(item: $editing) { StrainEditor(strain: $0) }
        .sheet(isPresented: $creating) { StrainEditor(strain: nil) }
    }
}

struct StrainRow: View {
    let strain: Strain

    private var subtitle: String {
        [strain.serialNumber.isEmpty ? nil : "#\(strain.serialNumber)",
         strain.hostOrganism.isEmpty ? nil : strain.hostOrganism,
         strain.plasmid.isEmpty ? nil : "plasmid \(strain.plasmid)"]
            .compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(strain.name).font(.headline)
            if !subtitle.isEmpty {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            }
            if !strain.selectionMarkers.isEmpty {
                HStack(spacing: 6) {
                    StatusChip(text: strain.selectionMarkers.joined(separator: ", "),
                               color: .teal)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
