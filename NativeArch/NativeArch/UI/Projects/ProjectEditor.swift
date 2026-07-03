import SwiftUI

/// Create (project == nil) or edit a project.
struct ProjectEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Project
    @State private var tagsText: String
    @State private var hasStart: Bool
    @State private var hasTarget: Bool
    private let isNew: Bool

    init(project: Project?) {
        _draft = State(initialValue: project ?? Project())
        _tagsText = State(initialValue: (project?.tags ?? []).joined(separator: ", "))
        _hasStart = State(initialValue: project?.startDate != nil)
        _hasTarget = State(initialValue: project?.targetDate != nil)
        isNew = project == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title)
                    TextField("Description", text: $draft.description, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section {
                    Picker("Status", selection: $draft.status) {
                        ForEach(ProjectStatus.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("Priority", selection: $draft.priority) {
                        ForEach(Priority.allCases) { Text($0.label).tag($0) }
                    }
                }
                Section("Dates") {
                    Toggle("Start date", isOn: $hasStart)
                    if hasStart {
                        DatePicker("Start", selection: Binding(
                            get: { draft.startDate ?? Date() },
                            set: { draft.startDate = $0 }), displayedComponents: .date)
                    }
                    Toggle("Target date", isOn: $hasTarget)
                    if hasTarget {
                        DatePicker("Target", selection: Binding(
                            get: { draft.targetDate ?? Date() },
                            set: { draft.targetDate = $0 }), displayedComponents: .date)
                    }
                }
                Section("Tags") {
                    TextField("Comma-separated", text: $tagsText)
                }
            }
            .navigationTitle(isNew ? "New project" : "Edit project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        if !hasStart { draft.startDate = nil }
        if !hasTarget { draft.targetDate = nil }
        draft.title = draft.title.trimmingCharacters(in: .whitespaces)
        draft.tags = tagsText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        store.saveProject(draft)
        dismiss()
    }
}
