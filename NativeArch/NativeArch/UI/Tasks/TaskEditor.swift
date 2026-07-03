import SwiftUI

struct TaskEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Task
    @State private var hasDue: Bool
    @State private var projectSel: String   // "" == none
    @State private var experimentSel: String
    private let isNew: Bool

    init(task: Task?) {
        _draft = State(initialValue: task ?? Task())
        _hasDue = State(initialValue: task?.dueDate != nil)
        _projectSel = State(initialValue: task?.projectId ?? "")
        _experimentSel = State(initialValue: task?.experimentId ?? "")
        isNew = task == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title)
                    TextField("Description", text: $draft.description, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section("Links") {
                    Picker("Project", selection: $projectSel) {
                        Text("None").tag("")
                        ForEach(store.projects) { Text($0.title).tag($0.id) }
                    }
                    Picker("Experiment", selection: $experimentSel) {
                        Text("None").tag("")
                        ForEach(store.experiments) { Text($0.title).tag($0.id) }
                    }
                }
                Section {
                    Picker("Status", selection: $draft.status) {
                        ForEach(TaskStatus.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("Priority", selection: $draft.priority) {
                        ForEach(Priority.allCases) { Text($0.label).tag($0) }
                    }
                    Toggle("Due date", isOn: $hasDue)
                    if hasDue {
                        DatePicker("Due", selection: Binding(
                            get: { draft.dueDate ?? Date() },
                            set: { draft.dueDate = $0 }), displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(isNew ? "New task" : "Edit task")
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
        if !hasDue { draft.dueDate = nil }
        draft.title = draft.title.trimmingCharacters(in: .whitespaces)
        draft.projectId = projectSel.isEmpty ? nil : projectSel
        draft.experimentId = experimentSel.isEmpty ? nil : experimentSel
        store.saveTask(draft)
        dismiss()
    }
}
