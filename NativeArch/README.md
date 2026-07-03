# NativeArch — native SwiftUI reforge of LabTrack

A ground-up rewrite of LabTrack in native SwiftUI for **iOS + macOS**, adopting
the **Liquid Glass** design system. Local-first, using the system SQLite library
(no third-party dependencies). Cloud sync (Supabase) is deferred to a later phase.

The original Flutter app remains at the repository root; this native app lives
under `NativeArch/`.

## Status — Phase 1 (foundation)

- SQLite data layer (`Data/`), schema ported from the drift tables
  (dates as unix-seconds, string lists as JSON, enums as text — matching the
  Flutter app for interop).
- Liquid Glass navigation shell (`UI/RootView.swift`): a `NavigationSplitView`
  sidebar listing all 16 sections.
- Two fully working sections: **Projects** and **Experiments** (list + create /
  edit / delete, wired to SQLite).
- Remaining sections show a "Coming soon" placeholder and are added
  incrementally.

## Generating the Xcode project

This repo intentionally does not commit a generated `.xcodeproj`. Create it with
[XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
cd NativeArch
brew install xcodegen      # if not installed
xcodegen generate
open NativeArch.xcodeproj
```

Or create a new **Multiplatform App** named `NativeArch` in Xcode and add the
`NativeArch/` source folder.

Requirements: Xcode 26+, iOS 26 / macOS 26 deployment targets (Liquid Glass).
