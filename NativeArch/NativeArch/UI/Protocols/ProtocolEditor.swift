import SwiftUI

struct ProtocolEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: LabProtocol
    private let isNew: Bool

    init(proto: LabProtocol?) {
        _draft = State(initialValue: proto ?? LabProtocol())
        isNew = proto == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name)
                    TextField("Category", text: $draft.category)
                    TextField("Summary", text: $draft.summary, axis: .vertical).lineLimit(2...5)
                }
                Section("Steps") {
                    ForEach(draft.steps.indices, id: \.self) { i in
                        HStack(alignment: .top) {
                            Text("\(i + 1).").foregroundStyle(.secondary)
                            TextField("Step \(i + 1)", text: $draft.steps[i], axis: .vertical)
                            Button { draft.steps.remove(at: i) } label: {
                                Image(systemName: "minus.circle")
                            }.buttonStyle(.borderless)
                        }
                    }
                    Button { draft.steps.append("") } label: {
                        Label("Add step", systemImage: "plus")
                    }
                }
                Section {
                    TextField("Materials", text: $draft.materials, axis: .vertical).lineLimit(2...5)
                    TextField("Notes", text: $draft.notes, axis: .vertical).lineLimit(2...5)
                }
            }
            .navigationTitle(isNew ? "New protocol" : "Edit protocol")
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
        draft.steps = draft.steps.map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        store.saveProtocol(draft)
        dismiss()
    }
}
