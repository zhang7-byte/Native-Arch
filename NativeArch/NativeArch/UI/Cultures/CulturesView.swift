import SwiftUI

struct CulturesView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Culture?
    @State private var creating = false
    @State private var scope = "active" // active | all

    private var shown: [Culture] {
        scope == "active" ? store.cultures.filter { $0.status == .active } : store.cultures
    }

    var body: some View {
        List {
            ForEach(shown) { culture in
                Button { editing = culture } label: { CultureRow(culture: culture) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteCulture(culture.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Cultures")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Scope", selection: $scope) {
                    Text("Active").tag("active")
                    Text("All").tag("all")
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New culture", systemImage: "plus") }
            }
        }
        .overlay {
            if shown.isEmpty {
                ContentUnavailableView("No cultures", systemImage: "drop",
                    description: Text("Tap + to start one."))
            }
        }
        .sheet(item: $editing) { CultureEditor(culture: $0) }
        .sheet(isPresented: $creating) { CultureEditor(culture: nil) }
    }
}

struct CultureRow: View {
    @Environment(AppStore.self) private var store
    let culture: Culture

    private var meta: String {
        [culture.strainId != nil ? store.strainName(culture.strainId) : nil,
         culture.medium.isEmpty ? nil : culture.medium,
         culture.startedDate.formatted(date: .abbreviated, time: .omitted)]
            .compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(culture.name.isEmpty ? "Untitled culture" : culture.name).font(.headline)
            Text(meta).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            StatusChip(text: culture.status.label, color: Palette.color(for: culture.status))
        }
        .padding(.vertical, 4)
    }
}
