import SwiftUI

struct CultureEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Culture
    @State private var strainSel: String
    @State private var markersText: String
    @State private var hasEnded: Bool
    @State private var events: [CultureEvent] = []
    @State private var editingEvent: CultureEvent?
    @State private var addingEvent = false
    private let isNew: Bool

    init(culture: Culture?) {
        _draft = State(initialValue: culture ?? Culture())
        _strainSel = State(initialValue: culture?.strainId ?? "")
        _markersText = State(initialValue: (culture?.selectionMarkers ?? []).joined(separator: ", "))
        _hasEnded = State(initialValue: culture?.endedDate != nil)
        isNew = culture == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name)
                    Picker("Strain", selection: $strainSel) {
                        Text("None").tag("")
                        ForEach(store.strains) { Text($0.name).tag($0.id) }
                    }
                    Picker("Status", selection: $draft.status) {
                        ForEach(CultureStatus.allCases) { Text($0.label).tag($0) }
                    }
                }
                Section {
                    TextField("Medium", text: $draft.medium)
                    TextField("Vessel", text: $draft.vessel)
                    TextField("Purpose", text: $draft.purpose, axis: .vertical).lineLimit(1...3)
                    TextField("Inoculum amount", text: $draft.inoculumAmount)
                    TextField("Selection markers (comma-separated)", text: $markersText)
                }
                Section("Dates") {
                    DatePicker("Started", selection: $draft.startedDate, displayedComponents: .date)
                    Toggle("Ended", isOn: $hasEnded)
                    if hasEnded {
                        DatePicker("Ended", selection: Binding(
                            get: { draft.endedDate ?? Date() },
                            set: { draft.endedDate = $0 }), displayedComponents: .date)
                    }
                }
                Section {
                    TextField("Notes", text: $draft.notes, axis: .vertical).lineLimit(2...5)
                }
                operationsSection
            }
            .navigationTitle(isNew ? "New culture" : "Edit culture")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
            .onAppear { if !isNew { events = store.events(for: draft.id) } }
            .sheet(item: $editingEvent) { ev in
                CultureEventEditor(event: ev) { saved in
                    store.saveEvent(saved); events = store.events(for: draft.id)
                }
            }
            .sheet(isPresented: $addingEvent) {
                CultureEventEditor(event: CultureEvent(cultureId: draft.id)) { saved in
                    store.saveEvent(saved); events = store.events(for: draft.id)
                }
            }
        }
    }

    @ViewBuilder private var operationsSection: some View {
        if isNew {
            Section("Operations") {
                Text("Save the culture first to log operations.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        } else {
            Section("Operations") {
                ForEach(events) { ev in
                    Button { editingEvent = ev } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(ev.type.label).font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(ev.happenedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            let detail = [ev.agent, ev.amount, ev.note]
                                .filter { !$0.isEmpty }.joined(separator: " · ")
                            if !detail.isEmpty {
                                Text(detail).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            store.deleteEvent(ev.id); events = store.events(for: draft.id)
                        } label: { Label("Delete", systemImage: "trash") }
                    }
                }
                Button { addingEvent = true } label: {
                    Label("Log operation", systemImage: "plus")
                }
            }
        }
    }

    private func save() {
        draft.strainId = strainSel.isEmpty ? nil : strainSel
        if !hasEnded { draft.endedDate = nil }
        draft.selectionMarkers = markersText.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        store.saveCulture(draft)
        dismiss()
    }
}

struct CultureEventEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: CultureEvent
    let onSave: (CultureEvent) -> Void

    init(event: CultureEvent, onSave: @escaping (CultureEvent) -> Void) {
        _draft = State(initialValue: event)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $draft.type) {
                    ForEach(CultureEventType.allCases) { Text($0.label).tag($0) }
                }
                DatePicker("When", selection: $draft.happenedAt)
                TextField("Agent (what)", text: $draft.agent)
                TextField("Amount / value", text: $draft.amount)
                TextField("Note", text: $draft.note, axis: .vertical).lineLimit(2...5)
            }
            .navigationTitle("Operation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(draft); dismiss() }
                }
            }
        }
    }
}
