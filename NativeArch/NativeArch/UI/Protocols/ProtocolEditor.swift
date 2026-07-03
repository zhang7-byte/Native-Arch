import SwiftUI
import UniformTypeIdentifiers

struct ProtocolEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: LabProtocol
    @State private var pdfDoc = PDFFileDocument()
    @State private var showPDF = false
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
                ToolbarItem {
                    Button {
                        pdfDoc = PDFFileDocument(data: renderPDF(ProtocolPDFView(proto: draft)))
                        showPDF = true
                    } label: { Label("Export PDF", systemImage: "arrow.down.doc") }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .fileExporter(isPresented: $showPDF, document: pdfDoc, contentType: .pdf,
                          defaultFilename: draft.name.isEmpty ? "protocol" : draft.name) { _ in }
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

/// The printable layout for a protocol PDF.
struct ProtocolPDFView: View {
    let proto: LabProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(proto.name).font(.system(size: 24, weight: .bold))
            if !proto.category.isEmpty {
                Text(proto.category).font(.system(size: 12)).foregroundStyle(.secondary)
            }
            if !proto.summary.isEmpty { Text(proto.summary).font(.system(size: 12)) }
            Divider()
            ForEach(Array(proto.steps.enumerated()), id: \.offset) { i, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(i + 1).").font(.system(size: 12, weight: .semibold))
                    Text(step).font(.system(size: 12))
                }
            }
            if !proto.materials.isEmpty {
                Divider()
                Text("Materials").font(.system(size: 13, weight: .semibold))
                Text(proto.materials).font(.system(size: 12))
            }
            Spacer(minLength: 0)
        }
        .padding(36)
        .foregroundStyle(.black)
    }
}
