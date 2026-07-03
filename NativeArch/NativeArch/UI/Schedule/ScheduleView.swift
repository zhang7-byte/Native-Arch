import SwiftUI

struct ScheduleView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: CustomEvent?
    @State private var creating = false

    private var startOfToday: Date { Calendar.current.startOfDay(for: Date()) }

    private struct Agenda: Identifiable {
        let id: String
        let date: Date
        let title: String
        let detail: String
        let icon: String
        let custom: CustomEvent?
    }

    /// Next occurrence for an annually-repeating event, else its own date.
    private func effectiveDate(_ e: CustomEvent) -> Date {
        guard e.repeatAnnually else { return e.date }
        let cal = Calendar.current
        let comps = cal.dateComponents([.month, .day], from: e.date)
        var next = cal.nextDate(after: startOfToday.addingTimeInterval(-1),
                                matching: comps, matchingPolicy: .nextTime) ?? e.date
        if next < startOfToday { next = e.date }
        return next
    }

    private var agenda: [Agenda] {
        var out: [Agenda] = []
        for e in store.customEvents {
            out.append(Agenda(id: "c-\(e.id)", date: effectiveDate(e), title: e.title,
                              detail: e.category.label, icon: e.category.icon, custom: e))
        }
        for p in store.projects {
            if let d = p.startDate { out.append(Agenda(id: "ps-\(p.id)", date: d,
                title: p.title, detail: "Project start", icon: "flask", custom: nil)) }
            if let d = p.targetDate { out.append(Agenda(id: "pt-\(p.id)", date: d,
                title: p.title, detail: "Project target", icon: "flask", custom: nil)) }
        }
        for e in store.experiments where e.date != nil {
            out.append(Agenda(id: "e-\(e.id)", date: e.date!, title: e.title,
                detail: "Experiment", icon: "testtube.2", custom: nil))
        }
        for t in store.tasks where t.dueDate != nil {
            out.append(Agenda(id: "t-\(t.id)", date: t.dueDate!, title: t.title,
                detail: "Task due", icon: "checklist", custom: nil))
        }
        return out.filter { $0.date >= startOfToday }.sorted { $0.date < $1.date }
    }

    var body: some View {
        List {
            ForEach(agenda) { item in
                Button { if let c = item.custom { editing = c } } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.icon).foregroundStyle(.tint).frame(width: 22)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title).font(.subheadline.weight(.medium)).lineLimit(1)
                            Text("\(item.detail) · \(item.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    if let c = item.custom {
                        Button(role: .destructive) { store.deleteCustomEvent(c.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New event", systemImage: "plus") }
            }
        }
        .overlay {
            if agenda.isEmpty {
                ContentUnavailableView("Nothing scheduled", systemImage: "calendar",
                    description: Text("Add an event, or set dates on your lab data."))
            }
        }
        .sheet(item: $editing) { CustomEventEditor(event: $0) }
        .sheet(isPresented: $creating) { CustomEventEditor(event: nil) }
    }
}

struct CustomEventEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: CustomEvent
    private let isNew: Bool

    init(event: CustomEvent?) {
        _draft = State(initialValue: event ?? CustomEvent())
        isNew = event == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $draft.title)
                DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                Picker("Category", selection: $draft.category) {
                    ForEach(EventCategory.allCases) { Label($0.label, systemImage: $0.icon).tag($0) }
                }
                Toggle("Repeat annually", isOn: $draft.repeatAnnually)
                TextField("Note", text: $draft.note, axis: .vertical).lineLimit(2...5)
            }
            .navigationTitle(isNew ? "New event" : "Edit event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        draft.title = draft.title.trimmingCharacters(in: .whitespaces)
                        store.saveCustomEvent(draft); dismiss()
                    }
                    .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
