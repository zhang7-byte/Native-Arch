# LabTrack — Data Model (schema v1)

Local-first SQLite schema for the Su Lab research PM app, implementing
[SPEC.md](SPEC.md) Section 3 with [drift](https://drift.simonbinder.eu/). The same
schema runs on every target (Windows, macOS, iOS, Android via native SQLite; web
via SQLite compiled to WebAssembly). Source of truth in code:
[lib/data/tables.dart](lib/data/tables.dart),
[lib/data/enums.dart](lib/data/enums.dart),
[lib/data/converters.dart](lib/data/converters.dart),
[lib/data/database.dart](lib/data/database.dart).

## Conventions (every table)

| Column | Type | Notes |
| --- | --- | --- |
| `id` | TEXT, PK | Client-generated **UUID v4**. Chosen over autoincrement so rows created offline on multiple devices never collide — a prerequisite for sync. |
| `created_at` | DateTime | Set once at insert. Stored as **ISO-8601 UTC text**. |
| `updated_at` | DateTime | Refreshed on every UPDATE by a DB-level `AFTER UPDATE` trigger (basis for last-writer-wins sync). ISO-8601 UTC text. |

- **Enums** are stored as their exact SPEC string via drift `textEnum` (e.g.
  `manuscript_prep`), guarded by a test.
- **List fields** (`tags`, `data_links`, `strain_ids`) are stored as a JSON text
  array via a `TypeConverter` (SQLite has no array type).
- **String fields** are non-null with a default of `''` (matching SPEC's `string`
  type); only `*_date` fields are nullable.
- **DateTime** columns are stored as ISO-8601 text for clean mapping onto Postgres
  `timestamptz` later.
- **Foreign keys** are enforced (`PRAGMA foreign_keys = ON`), with indexes on FK columns.

## Tables

### `projects`
| Column | Type | Null | Default |
| --- | --- | --- | --- |
| title | TEXT | no | — |
| description | TEXT | no | `''` |
| status | TEXT (`ProjectStatus`) | no | `planning` |
| priority | TEXT (`Priority`) | no | `medium` |
| start_date | DateTime | yes | — |
| target_date | DateTime | yes | — |
| tags | TEXT (JSON `List<String>`) | no | `[]` |

### `experiments`  — index on `project_id`
| Column | Type | Null | Default |
| --- | --- | --- | --- |
| project_id | TEXT → `projects.id` (CASCADE) | no | — |
| title | TEXT | no | — |
| hypothesis | TEXT | no | `''` |
| status | TEXT (`ExperimentStatus`) | no | `planned` |
| date | DateTime | yes | — |
| strain_ids | TEXT (JSON `List<String>`) | no | `[]` |
| protocol_ref | TEXT | no | `''` |
| results_notes | TEXT | no | `''` |
| data_links | TEXT (JSON `List<String>`) | no | `[]` |

`strain_ids` is a **logical** FK array to `strains.id` (per SPEC, no join table in
v1) — resolved in the app layer, so missing IDs degrade gracefully.

### `tasks`  — indexes on `project_id`, `experiment_id`
| Column | Type | Null | Default |
| --- | --- | --- | --- |
| project_id | TEXT → `projects.id` (CASCADE) | **yes** | — |
| experiment_id | TEXT → `experiments.id` (CASCADE) | **yes** | — |
| title | TEXT | no | — |
| description | TEXT | no | `''` |
| due_date | DateTime | yes | — |
| status | TEXT (`TaskStatus`) | no | `todo` |
| priority | TEXT (`Priority`) | no | `medium` |

### `strains`
| Column | Type | Null | Default |
| --- | --- | --- | --- |
| name | TEXT | no | — |
| host_organism | TEXT | no | `''` |
| genotype | TEXT | no | `''` |
| plasmid | TEXT | no | `''` |
| construct_notes | TEXT | no | `''` |
| freezer_location | TEXT | no | `''` |
| notes | TEXT | no | `''` |

### `reagents`
| Column | Type | Null | Default |
| --- | --- | --- | --- |
| name | TEXT | no | — |
| supplier | TEXT | no | `''` |
| catalog_no | TEXT | no | `''` |
| lot | TEXT | no | `''` |
| location | TEXT | no | `''` |
| expiry_date | DateTime | yes | — |
| quantity | TEXT | no | `''` |
| notes | TEXT | no | `''` |

### `manuscripts`  — index on `project_id`
| Column | Type | Null | Default |
| --- | --- | --- | --- |
| project_id | TEXT → `projects.id` (CASCADE) | no | — |
| title | TEXT | no | — |
| target_journal | TEXT | no | `''` |
| status | TEXT (`ManuscriptStatus`) | no | `drafting` |
| submission_id | TEXT | no | `''` |
| submitted_date | DateTime | yes | — |
| notes | TEXT | no | `''` |

## Enumerations (stored value = constant name)

- **ProjectStatus**: `planning`, `active`, `manuscript_prep`, `under_review`, `published`, `shelved`
- **Priority**: `low`, `medium`, `high`  *(Project + Task)*
- **ExperimentStatus**: `planned`, `running`, `done`, `failed`
- **TaskStatus**: `todo`, `doing`, `done`, `blocked`
- **ManuscriptStatus**: `drafting`, `submitted`, `revision`, `accepted`, `published`

## Relationships

```
projects 1──< experiments        (experiments.project_id, required, ON DELETE CASCADE)
projects 1──< manuscripts        (manuscripts.project_id, required, ON DELETE CASCADE)
projects 1──< tasks              (tasks.project_id, optional, ON DELETE CASCADE)
experiments 1──< tasks           (tasks.experiment_id, optional, ON DELETE CASCADE)
experiments >──< strains         (experiments.strain_ids JSON array; resolved in app, no join table in v1)
strains, reagents                (standalone inventory, project-independent)
```

## Deliberately deferred to the sync stage (Stage 5)

Raised by an adversarial schema review and consciously left for the sync design,
not omissions:

1. **Soft-delete / tombstones** for propagating deletes across devices.
2. **Postgres mapping** for JSON list columns (`jsonb` recommended).
3. **Server-side enum/CHECK constraints** (SQLite stores status as free text).
4. **Enum names are a storage contract** — renaming a constant needs a data
   migration. Guarded by a test for now.
