import SwiftUI

struct CloneEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: CloneConstruction
    private let isNew: Bool

    init(clone: CloneConstruction?) {
        _draft = State(initialValue: clone ?? CloneConstruction())
        isNew = clone == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name)
                    TextField("Notes", text: $draft.notes, axis: .vertical).lineLimit(2...4)
                }
                Section("Backbone") {
                    TextField("Vector name", text: $draft.backboneName)
                    Picker("Stock strain", selection: $draft.backboneStrainId) {
                        Text("None").tag("")
                        ForEach(store.strains) { Text($0.name).tag($0.id) }
                    }
                    TextField("Enzymes", text: $draft.enzymes)
                }
                ForEach($draft.fragments) { $fragment in
                    fragmentSection($fragment)
                }
                Section {
                    Button {
                        draft.fragments.append(CloneFragment())
                    } label: { Label("Add fragment", systemImage: "plus") }
                }
            }
            .navigationTitle(isNew ? "New construction" : "Edit construction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
        }
    }

    private func fragmentSection(_ fragment: Binding<CloneFragment>) -> some View {
        Section("Fragment") {
            TextField("Name", text: fragment.name)
            Picker("Template strain", selection: fragment.templateStrainId) {
                Text("None").tag("")
                ForEach(store.strains) { Text($0.name).tag($0.id) }
            }
            Picker("Forward primer", selection: fragment.fwdPrimerId) {
                Text("None").tag("")
                ForEach(store.primers) { Text($0.name).tag($0.id) }
            }
            Picker("Reverse primer", selection: fragment.revPrimerId) {
                Text("None").tag("")
                ForEach(store.primers) { Text($0.name).tag($0.id) }
            }
            TextField("Amplicon size (e.g. 1.2 kb)", text: fragment.sizeBp)
            TextField("Notes", text: fragment.notes, axis: .vertical).lineLimit(1...3)
            Button(role: .destructive) {
                draft.fragments.removeAll { $0.id == fragment.wrappedValue.id }
            } label: { Label("Remove fragment", systemImage: "trash") }
        }
    }

    private func save() {
        draft.name = draft.name.trimmingCharacters(in: .whitespaces)
        store.saveClone(draft)
        dismiss()
    }
}
