import SwiftUI

/// Create (experiment == nil) or edit an experiment.
struct ExperimentEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Experiment
    @State private var hasDate: Bool
    @State private var dataLinksText: String
    private let isNew: Bool

    init(experiment: Experiment?) {
        _draft = State(initialValue: experiment ?? Experiment())
        _hasDate = State(initialValue: experiment?.date != nil)
        _dataLinksText = State(initialValue: (experiment?.dataLinks ?? []).joined(separator: ", "))
        isNew = experiment == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Project", selection: $draft.projectId) {
                        ForEach(store.projects) { Text($0.title).tag($0.id) }
                    }
                    TextField("Title", text: $draft.title)
                    TextField("Hypothesis", text: $draft.hypothesis, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section {
                    Picker("Status", selection: $draft.status) {
                        ForEach(ExperimentStatus.allCases) { Text($0.label).tag($0) }
                    }
                    Toggle("Date", isOn: $hasDate)
                    if hasDate {
                        DatePicker("Date", selection: Binding(
                            get: { draft.date ?? Date() },
                            set: { draft.date = $0 }), displayedComponents: .date)
                    }
                    TextField("Protocol ref", text: $draft.protocolRef)
                }
                methodologySection
                Section {
                    TextField("Results notes", text: $draft.resultsNotes, axis: .vertical)
                        .lineLimit(2...6)
                    TextField("Conclusion", text: $draft.conclusion, axis: .vertical)
                        .lineLimit(2...6)
                    TextField("Further plan", text: $draft.furtherPlan, axis: .vertical)
                        .lineLimit(2...6)
                }
                Section("Data links") {
                    TextField("Comma-separated URLs", text: $dataLinksText)
                }
            }
            .navigationTitle(isNew ? "New experiment" : "Edit experiment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty
                                  || draft.projectId.isEmpty)
                }
            }
            .onAppear {
                if draft.projectId.isEmpty { draft.projectId = store.projects.first?.id ?? "" }
            }
        }
    }

    private var methodologySection: some View {
        Section("Methodology (step by step)") {
            ForEach(draft.methodologySteps.indices, id: \.self) { i in
                HStack {
                    Text("\(i + 1).").foregroundStyle(.secondary)
                    TextField("Step \(i + 1)", text: $draft.methodologySteps[i], axis: .vertical)
                    Button {
                        draft.methodologySteps.remove(at: i)
                    } label: { Image(systemName: "minus.circle") }
                        .buttonStyle(.borderless)
                }
            }
            Button {
                draft.methodologySteps.append("")
            } label: { Label("Add step", systemImage: "plus") }
        }
    }

    private func save() {
        if !hasDate { draft.date = nil }
        draft.title = draft.title.trimmingCharacters(in: .whitespaces)
        draft.methodologySteps = draft.methodologySteps
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        draft.dataLinks = dataLinksText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        store.saveExperiment(draft)
        dismiss()
    }
}
