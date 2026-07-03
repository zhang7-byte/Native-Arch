import SwiftUI

struct WorkspaceView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Workspace?
    @State private var creating = false
    @State private var currentId: String?

    var body: some View {
        List {
            Section {
                Text("Workspaces group your lab data. Data scoping across workspaces is a later phase — for now this manages the workspace list and the active selection.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Workspaces") {
                ForEach(store.workspaces) { ws in
                    HStack {
                        Button { editing = ws } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ws.name).font(.headline)
                                if ws.id == currentId {
                                    Text("Current").font(.caption).foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        if ws.id == currentId {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                        } else {
                            Button("Use") { store.currentWorkspaceId = ws.id; currentId = ws.id }
                                .buttonStyle(.bordered)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteWorkspace(ws.id); currentId = store.currentWorkspaceId } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Workspace")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New workspace", systemImage: "plus") }
            }
        }
        .overlay {
            if store.workspaces.isEmpty {
                ContentUnavailableView("No workspaces", systemImage: "person.2",
                    description: Text("Tap + to create one."))
            }
        }
        .onAppear { currentId = store.currentWorkspaceId }
        .sheet(item: $editing) { WorkspaceEditor(workspace: $0) }
        .sheet(isPresented: $creating) { WorkspaceEditor(workspace: nil) }
    }
}

struct WorkspaceEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Workspace
    private let isNew: Bool

    init(workspace: Workspace?) {
        _draft = State(initialValue: workspace ?? Workspace())
        isNew = workspace == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $draft.name)
            }
            .navigationTitle(isNew ? "New workspace" : "Rename workspace")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        draft.name = draft.name.trimmingCharacters(in: .whitespaces)
                        store.saveWorkspace(draft); dismiss()
                    }
                    .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
