# LabTrack

Local-first project management for bioscience research. One Flutter codebase
targeting **Windows, macOS, iOS, Android**, with local SQLite persistence and
two-way **Supabase sync**.

> **Progress (SPEC.md build sequence) — all stages complete:** Stage 1 (schema) ✓
> · Stage 2 (Projects CRUD + seed) ✓ · Stage 3 (Experiments + Tasks) ✓ · Stage 4
> (Strain + Reagent inventory) ✓ · Stage 5 (Supabase auth + two-way sync) ✓ ·
> Stage 6 (status board, project filters, deadline view + due-today notification,
> dashboard) ✓. The app is an adaptive Dashboard / Projects / Board / Deadlines /
> Experiments / Tasks / Strains / Reagents navigator (NavigationRail on wide
> screens, bottom bar + "More" on phones) with create/edit/delete persisted to
> local SQLite and optional cloud sync. See [SPEC.md](SPEC.md) for the plan,
> [SCHEMA.md](SCHEMA.md) for the data model, and [SYNC.md](SYNC.md) for sync setup.

## Stack (pinned)

| Component | Version | Why |
| --- | --- | --- |
| Flutter | **3.44.4** (stable) | One codebase → true native on all 4 targets |
| Dart | **3.12.2** | Bundled with Flutter |
| drift | **2.34.0** | Typed SQLite ORM: schema, queries, migrations |
| drift_flutter | **0.3.0** | Opens the DB natively (file) and on web (WASM) |
| drift_dev / build_runner | **2.34.1+1 / 2.15.0** | Code generation |
| sqlite3 / sqlite3_flutter_libs | **3.3.3 / 0.6.0+eol** | SQLite engine + native libs |
| path_provider | **2.1.6** | On-device DB file location |
| uuid | **4.5.3** | UUID v4 primary keys (sync-safe) |
| supabase_flutter | **2.15.0** | Auth + Postgres/Realtime client for two-way sync |

All app dependencies are pinned to exact versions in
[pubspec.yaml](pubspec.yaml); transitive versions are locked in `pubspec.lock`.

> **Web + Supabase note.** `supabase_flutter` transitively pulls `passkeys_web`,
> whose web registration calls `window.close()` (aborting the app) if a global
> `PasskeyAuthenticator` is missing. LabTrack uses email/password auth, so
> [web/index.html](web/index.html) defines a tiny no-op stub for it — no external
> SDK, fully offline. See [SYNC.md](SYNC.md) to enable cloud sync.

> Note: `sqlite3_flutter_libs 0.6.0+eol` carries upstream's end-of-life tag but
> is the version drift_flutter 0.3.0 resolves to and is fully functional. Revisit
> when drift_flutter ships a successor.

## Data layer at a glance

- **UUID v4 text primary keys** so offline rows on different devices never collide.
- **Status enums** stored as their exact spec string (`textEnum`).
- **`List<String>` fields** (tags, data_links) stored as JSON text.
- **`created_at` / `updated_at`** on every row; `updated_at` is refreshed by a
  DB-level `AFTER UPDATE` trigger (last-writer-wins basis). Timestamps are UTC.
- **Foreign keys** enforced (`PRAGMA foreign_keys = ON`), with indexes on FK columns.

Full details and the deferred sync-stage decisions: [SCHEMA.md](SCHEMA.md).

## Running

This stage is verified on **web (Chrome)**, which needs no extra toolchain beyond
the Flutter SDK:

```sh
flutter pub get
dart run build_runner build      # generate database.g.dart (committed-by-build)
flutter run -d chrome            # launches the blank app; logs a DB smoke check
```

The blank app opens the local database at startup and prints a one-line smoke
check (table list + row count) to the console.

### Other platforms (later stages)

The platform folders are already scaffolded. To build natively you'll need the
usual per-platform toolchains, which are **not** required for this stage:

- **Windows desktop:** Visual Studio 2022 with the "Desktop development with C++" workload.
- **Android:** Android Studio / Android SDK.
- **macOS / iOS:** Xcode (on a Mac).

The web build loads two assets from [web/](web/): `sqlite3.wasm` and
`drift_worker.js` (version-matched to the `sqlite3` and `drift` packages).

## Tests

```sh
flutter test
```

Covers schema creation, UUID/enum/int defaults, the JSON list converter, FK
cascade, the `updated_at` trigger, and the enum wire-format contract. The native
test loads `sqlite3.dll` (in the repo root) for the in-memory SQLite engine.

## Project structure

```
lib/
  main.dart              # blank app + startup DB smoke check
  data/
    database.dart        # AppDatabase, migrations, updated_at triggers
    database.g.dart      # generated (drift)
    tables.dart          # 6 table definitions + shared base columns
    enums.dart           # status enumerations (stored as text)
    converters.dart      # List<String> <-> JSON text
web/
  sqlite3.wasm, drift_worker.js   # web SQLite runtime
test/
  database_test.dart, widget_test.dart
SCHEMA.md                # the data model
```
