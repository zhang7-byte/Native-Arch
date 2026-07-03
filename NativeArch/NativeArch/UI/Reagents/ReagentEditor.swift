import SwiftUI

struct ReagentEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Reagent
    @State private var hasExpiry: Bool
    private let isNew: Bool

    init(reagent: Reagent?, initialKind: String = "reagent") {
        var initial = reagent ?? Reagent()
        if reagent == nil { initial.kind = initialKind }
        _draft = State(initialValue: initial)
        _hasExpiry = State(initialValue: reagent?.expiryDate != nil)
        isNew = reagent == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name)
                    Picker("Kind", selection: $draft.kind) {
                        Text("Reagent").tag("reagent")
                        Text("Buffer").tag("buffer")
                    }
                    .pickerStyle(.segmented)
                }
                if draft.isBuffer {
                    Section("Recipe") {
                        TextField("Preparation / composition", text: $draft.recipe, axis: .vertical)
                            .lineLimit(3...8)
                    }
                } else {
                    Section {
                        TextField("Supplier", text: $draft.supplier)
                        TextField("Catalog no.", text: $draft.catalogNo)
                        TextField("Lot", text: $draft.lot)
                    }
                }
                Section {
                    TextField("Location", text: $draft.location)
                    TextField("Quantity", text: $draft.quantity)
                    Toggle("Expiry date", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("Expiry", selection: Binding(
                            get: { draft.expiryDate ?? Date() },
                            set: { draft.expiryDate = $0 }), displayedComponents: .date)
                    }
                    TextField("Notes", text: $draft.notes, axis: .vertical).lineLimit(2...5)
                }
            }
            .navigationTitle(isNew ? "New \(draft.isBuffer ? "buffer" : "reagent")" : "Edit")
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
        if !hasExpiry { draft.expiryDate = nil }
        draft.name = draft.name.trimmingCharacters(in: .whitespaces)
        store.saveReagent(draft)
        dismiss()
    }
}
