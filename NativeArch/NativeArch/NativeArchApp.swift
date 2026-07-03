import SwiftUI

/// LabTrack — native SwiftUI reforge (Native-Arch).
///
/// A local-first lab-management app for iOS + macOS. This is the Phase 1
/// foundation: the SQLite data layer (schema ported from the Flutter/drift
/// app), a Liquid Glass navigation shell, and two fully working sections
/// (Projects, Experiments). Remaining sections are added incrementally.
@main
struct NativeArchApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(Color(argb: store.settings.accentColor))
                .preferredColorScheme(colorScheme(for: store.settings.themeMode))
        }
        #if os(macOS)
        .defaultSize(width: 1100, height: 720)
        #endif
    }
}
