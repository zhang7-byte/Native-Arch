import SwiftUI

struct ReportEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Report
    @State private var hasStart: Bool
    @State private var hasEnd: Bool
    private let isNew: Bool

    init(report: Report?) {
        _draft = State(initialValue: report ?? Report())
        _hasStart = State(initialValue: report?.periodStart != nil)
        _hasEnd = State(initialValue: report?.periodEnd != nil)
        isNew = report == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title)
                    TextField("Recipient (PI)", text: $draft.recipient)
                    TextField("Author", text: $draft.author)
                }
                Section("Reporting period") {
                    Toggle("Start", isOn: $hasStart)
                    if hasStart {
                        DatePicker("Start", selection: Binding(
                            get: { draft.periodStart ?? Date() },
                            set: { draft.periodStart = $0 }), displayedComponents: .date)
                    }
                    Toggle("End", isOn: $hasEnd)
                    if hasEnd {
                        DatePicker("End", selection: Binding(
                            get: { draft.periodEnd ?? Date() },
                            set: { draft.periodEnd = $0 }), displayedComponents: .date)
                    }
                }
                Section("Summary") {
                    TextField("Written summary", text: $draft.summary, axis: .vertical)
                        .lineLimit(4...12)
                }
            }
            .navigationTitle(isNew ? "New report" : "Edit report")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        if !hasStart { draft.periodStart = nil }
        if !hasEnd { draft.periodEnd = nil }
        draft.title = draft.title.trimmingCharacters(in: .whitespaces)
        store.saveReport(draft)
        dismiss()
    }
}
