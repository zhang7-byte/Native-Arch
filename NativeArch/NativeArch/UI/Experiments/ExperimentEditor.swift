import SwiftUI
import PhotosUI

/// Create (experiment == nil) or edit an experiment.
struct ExperimentEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Experiment
    @State private var hasDate: Bool
    @State private var dataLinksText: String
    private let isNew: Bool

    // Progress log + images (loaded on demand for an existing experiment).
    @State private var updates: [ExperimentUpdate] = []
    @State private var images: [AttachedImage] = []
    @State private var editingUpdate: ExperimentUpdate?
    @State private var addingUpdate = false
    @State private var photoItem: PhotosPickerItem?

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
                progressLogSection
                imagesSection
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
                if !isNew { reloadDetail() }
            }
            .onChange(of: photoItem) {
                guard let item = photoItem else { return }
                Swift.Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        store.addImage(data, experimentId: draft.id)
                        images = store.images(forExperiment: draft.id)
                    }
                    photoItem = nil
                }
            }
            .sheet(item: $editingUpdate) { u in
                UpdateEditor(update: u) { store.saveUpdate($0); reloadDetail() }
            }
            .sheet(isPresented: $addingUpdate) {
                UpdateEditor(update: ExperimentUpdate(experimentId: draft.id)) {
                    store.saveUpdate($0); reloadDetail()
                }
            }
        }
    }

    private func reloadDetail() {
        updates = store.updates(for: draft.id)
        images = store.images(forExperiment: draft.id)
    }

    @ViewBuilder private var progressLogSection: some View {
        if isNew {
            Section("Progress log") {
                Text("Save the experiment first to add log entries and images.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        } else {
            Section("Progress log") {
                ForEach(updates) { u in
                    Button { editingUpdate = u } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(u.happenedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundStyle(.secondary)
                            Text(u.note.isEmpty ? "(no note)" : u.note)
                                .font(.subheadline).lineLimit(3)
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            store.deleteUpdate(u.id); reloadDetail()
                        } label: { Label("Delete", systemImage: "trash") }
                    }
                }
                Button { addingUpdate = true } label: {
                    Label("Add log entry", systemImage: "plus")
                }
            }
        }
    }

    @ViewBuilder private var imagesSection: some View {
        if !isNew {
            Section("Images") {
                if !images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(images) { img in
                                if let data = store.imageBytes(img.id),
                                   let image = platformImage(from: data) {
                                    image.resizable().scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipShape(.rect(cornerRadius: 10))
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                store.deleteImage(img.id); reloadDetail()
                                            } label: { Label("Delete", systemImage: "trash") }
                                        }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Add image", systemImage: "photo.badge.plus")
                }
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

/// Edits a single progress-log entry.
struct UpdateEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ExperimentUpdate
    let onSave: (ExperimentUpdate) -> Void

    init(update: ExperimentUpdate, onSave: @escaping (ExperimentUpdate) -> Void) {
        _draft = State(initialValue: update)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("When", selection: $draft.happenedAt)
                TextField("Note", text: $draft.note, axis: .vertical).lineLimit(3...10)
            }
            .navigationTitle("Log entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(draft); dismiss() }
                }
            }
        }
    }
}
