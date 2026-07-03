import SwiftUI

struct PrimerEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Primer
    private let isNew: Bool

    init(primer: Primer?) {
        _draft = State(initialValue: primer ?? Primer())
        isNew = primer == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name)
                    TextField("Serial / catalog no.", text: $draft.serialNumber)
                }
                Section {
                    TextField("Sequence (5'→3')", text: $draft.sequence, axis: .vertical)
                        .lineLimit(2...5)
                        .font(.system(.body, design: .monospaced))
                    if draft.length > 0 {
                        Text("\(draft.length) nt").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Section {
                    TextField("Target gene", text: $draft.targetGene)
                    TextField("Direction (fwd/rev)", text: $draft.direction)
                    TextField("Tm", text: $draft.tm)
                    TextField("Supplier", text: $draft.supplier)
                    TextField("Notes", text: $draft.notes, axis: .vertical).lineLimit(2...5)
                }
            }
            .navigationTitle(isNew ? "New primer" : "Edit primer")
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
        store.savePrimer(draft)
        dismiss()
    }
}
