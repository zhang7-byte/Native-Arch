import SwiftUI

struct StrainEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Strain
    @State private var markersText: String
    private let isNew: Bool

    init(strain: Strain?) {
        _draft = State(initialValue: strain ?? Strain())
        _markersText = State(initialValue: (strain?.selectionMarkers ?? []).joined(separator: ", "))
        isNew = strain == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name)
                    TextField("Serial / catalog no.", text: $draft.serialNumber)
                    TextField("Host organism", text: $draft.hostOrganism)
                }
                Section {
                    TextField("Genotype", text: $draft.genotype)
                    TextField("Plasmid", text: $draft.plasmid)
                    TextField("Construct notes", text: $draft.constructNotes, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section("Selection markers") {
                    TextField("Comma-separated", text: $markersText)
                }
                Section {
                    TextField("Freezer location", text: $draft.freezerLocation)
                    TextField("Notes", text: $draft.notes, axis: .vertical).lineLimit(2...5)
                }
            }
            .navigationTitle(isNew ? "New strain" : "Edit strain")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        draft.name = draft.name.trimmingCharacters(in: .whitespaces)
        draft.selectionMarkers = markersText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        store.saveStrain(draft)
        dismiss()
    }
}
