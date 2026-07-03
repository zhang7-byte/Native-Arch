import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var store
    @State private var s = AppSettings()
    @State private var loaded = false

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $s.themeMode) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                Picker("Density", selection: $s.density) {
                    Text("Comfortable").tag("comfortable")
                    Text("Compact").tag("compact")
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Accent").font(.subheadline)
                    HStack(spacing: 12) {
                        ForEach(accentPresets, id: \.argb) { preset in
                            Circle()
                                .fill(Color(argb: preset.argb))
                                .frame(width: 28, height: 28)
                                .overlay {
                                    if s.accentColor == preset.argb {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold()).foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture { s.accentColor = preset.argb }
                        }
                    }
                }
            }
            Section("Notifications") {
                Picker("Deadline reminders", selection: $s.notifyFrequency) {
                    Text("Off").tag("off")
                    Text("Daily").tag("daily")
                    Text("Twice daily").tag("twice_daily")
                    Text("Every 6 hours").tag("every_6h")
                    Text("Hourly").tag("hourly")
                }
                Toggle("Notify today's schedule", isOn: $s.scheduleNotify)
            }
            Section("Schedule") {
                Picker("Holiday overlay", selection: $s.holidayRegion) {
                    Text("None").tag("none")
                    Text("US").tag("us")
                    Text("US — Hawaii").tag("us-hi")
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear { if !loaded { s = store.settings; loaded = true } }
        .onChange(of: s.themeMode) { store.saveSettings(s) }
        .onChange(of: s.density) { store.saveSettings(s) }
        .onChange(of: s.accentColor) { store.saveSettings(s) }
        .onChange(of: s.notifyFrequency) { store.saveSettings(s) }
        .onChange(of: s.scheduleNotify) { store.saveSettings(s) }
        .onChange(of: s.holidayRegion) { store.saveSettings(s) }
    }
}
