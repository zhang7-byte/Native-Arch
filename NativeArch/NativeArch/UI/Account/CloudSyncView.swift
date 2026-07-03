import SwiftUI

struct CloudSyncView: View {
    @Environment(AuthService.self) private var auth
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var url = ""
    @State private var anonKey = ""
    @State private var email = ""
    @State private var password = ""
    @State private var syncStatus = ""
    @State private var syncing = false

    var body: some View {
        NavigationStack {
            Form {
                if auth.isSignedIn {
                    Section("Signed in") {
                        LabeledContent("Account", value: auth.email)
                        Button("Sign out", role: .destructive) { auth.signOut() }
                    }
                    Section("Sync") {
                        Button { run { await store.push(using: auth) } } label: {
                            Label("Push to cloud", systemImage: "arrow.up.circle")
                        }.disabled(syncing)
                        Button { run { await store.pull(using: auth) } } label: {
                            Label("Pull from cloud", systemImage: "arrow.down.circle")
                        }.disabled(syncing)
                        if !syncStatus.isEmpty {
                            Text(syncStatus).font(.footnote).foregroundStyle(.secondary)
                        }
                        Text("Snapshot sync (compatible with the LabTrack cloud): Push overwrites the cloud copy with this device's data; Pull replaces this device's data with the cloud copy.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                } else {
                    Section("Supabase project") {
                        TextField("Project URL (https://xxxx.supabase.co)", text: $url)
                            .textContentType(.URL).autocorrectionDisabled()
                        SecureField("Anon / public key", text: $anonKey)
                    }
                    Section("Sign in") {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress).autocorrectionDisabled()
                        SecureField("Password", text: $password)
                        Button("Sign in") { submit(signUp: false) }
                            .disabled(auth.busy)
                        Button("Create account") { submit(signUp: true) }
                            .disabled(auth.busy)
                    }
                    if let err = auth.lastError {
                        Section { Text(err).foregroundStyle(.red).font(.footnote) }
                    }
                }
                Section {
                    Text("Two-way sync (push/pull) is added in the next step; this configures the connection and signs you in.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Cloud sync")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .onAppear { url = auth.config.url; anonKey = auth.config.anonKey }
            .overlay { if auth.busy { ProgressView().controlSize(.large) } }
        }
    }

    private func run(_ op: @escaping () async -> String) {
        syncing = true; syncStatus = ""
        Swift.Task {
            let msg = await op()
            syncStatus = msg; syncing = false
        }
    }

    private func submit(signUp: Bool) {
        auth.saveConfig(SyncConfig(url: url, anonKey: anonKey))
        Swift.Task {
            if signUp { await auth.signUp(email: email, password: password) }
            else { await auth.signIn(email: email, password: password) }
        }
    }
}
