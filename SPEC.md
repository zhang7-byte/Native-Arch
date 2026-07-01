# SPEC.md — Su Lab Research PM

A local-first project-management app for bioscience research, built for the Su Lab
(MBBE, UH Mānoa). Single user to start (Wei Zhang), with Zhenlin Han and
Solange Tofani as likely later collaborators, so the data layer is built to sync.

Keep this file in the repo root. At the start of every coding session, tell the
agent: **"Read SPEC.md before doing anything."** Update the relevant section
whenever a decision changes. The build tracks this file, not your memory.

---

## 1. Stack decision

Pick one before Stage 1 and delete the other. Every prompt below says
"the stack declared in this spec," so you only choose once.

**Default — React + Vite, shipped as an installable PWA.**
One codebase targeting Windows, macOS, iOS, Android. Installs to the dock and
home screen, runs offline, no app-store review. You give up deeper OS hooks and
some native polish; push notifications work but need a service worker. This
covers a research tracker fully. Recommended unless you have a concrete reason
it won't do.

**Alternative — Flutter.**
Choose this only if you need genuine native behaviour on all four platforms
(native widgets, background tasks, tight OS integration). One codebase, more
setup, app-store review for mobile. If you pick Flutter, the data model below
maps to Dart classes with Drift for the local DB; everything else holds.

> **Chosen for this build: Flutter** (Dart + Drift/SQLite), confirmed by Wei on
> 2025-06-25. Pinned versions and rationale are in README.md.

**Persistence:** SQLite locally from Stage 1.
**Sync:** Supabase (Postgres + auth + realtime), added at Stage 5. Nothing before
Stage 5 talks to a network.

---

## 2. Build sequence

Don't ask for the whole app at once. Six stages, one prompt each, each against
the running app from the previous stage. The full prompts are in Section 5.

1. Scaffold a project that builds and runs on one platform. Generate the schema
   and types. No UI beyond a blank running app.
2. Build the Project entity end to end: create, list, edit, delete, persist.
3. Add Experiments and Tasks, each linked to Projects.
4. Add the Strain and Reagent inventory.
5. Wire in Supabase and sync.
6. Add views and polish: filters, deadline reminders, a board, a dashboard.

Confirm the app actually runs at the end of each stage before starting the next.
Fixing the schema at Stage 1 costs minutes; fixing it after you've built screens
on top costs hours.

---

## 3. Data model

Schema shown in TypeScript for the React/PWA default. Flutter users map each type
to a Dart class plus a Drift table; the fields and enums are identical.

`id`, `created_at`, `updated_at` are present on every table and omitted below for
brevity. IDs are UUIDs. Dates are ISO 8601 strings.

```ts
type ProjectStatus =
  | "planning"
  | "active"
  | "manuscript_prep"
  | "under_review"
  | "published"
  | "shelved";

type Priority = "low" | "medium" | "high";

interface Project {
  title: string;
  description: string;
  status: ProjectStatus;
  priority: Priority;
  start_date: string | null;
  target_date: string | null;
  tags: string[];
}

type ExperimentStatus = "planned" | "running" | "done" | "failed";

interface Experiment {
  project_id: string;            // FK -> Project
  title: string;
  hypothesis: string;
  status: ExperimentStatus;
  date: string | null;
  strain_ids: string[];          // FK -> Strain (which strains this run used)
  protocol_ref: string;          // e.g. "LiAc/PEG transformation v3"
  results_notes: string;
  data_links: string[];          // URLs: raw data, BioRender, Drive, instrument exports
}

type TaskStatus = "todo" | "doing" | "done" | "blocked";

interface Task {
  project_id: string | null;     // FK -> Project (optional)
  experiment_id: string | null;  // FK -> Experiment (optional)
  title: string;
  description: string;
  due_date: string | null;
  status: TaskStatus;
  priority: Priority;
}

interface Strain {
  name: string;                  // e.g. "2542"
  host_organism: string;         // e.g. "Yarrowia lipolytica"
  genotype: string;
  plasmid: string;               // e.g. "p5219"
  construct_notes: string;       // e.g. "dGFP(V8A) + AID2"
  freezer_location: string;
  notes: string;
}

interface Reagent {
  name: string;
  supplier: string;
  catalog_no: string;
  lot: string;
  location: string;
  expiry_date: string | null;
  quantity: string;
  notes: string;
}

type ManuscriptStatus =
  | "drafting"
  | "submitted"
  | "revision"
  | "accepted"
  | "published";

interface Manuscript {
  project_id: string;            // FK -> Project
  title: string;
  target_journal: string;
  status: ManuscriptStatus;
  submission_id: string;         // e.g. "sb-2025-009706.R1"
  submitted_date: string | null;
  notes: string;
}
```

Relationships: a Project has many Experiments, Tasks, and Manuscripts. An
Experiment has many Tasks and references many Strains. Strains and Reagents are
standalone inventory that Experiments point at. If you later want a strain to
list every project it appears in, add a `strain_projects` join table; the
`strain_ids[]` array on Experiment is enough for v1.

---

## 4. Seed data

Drop this in after Stage 2 so you have real records to build against. Format is
portable JSON; have the agent convert it to the chosen stack's insert format.
IDs are placeholders (`prj-001` etc.) — replace with UUIDs on insert, keeping the
foreign-key references consistent.

Genotype fields marked `VERIFY` are placeholders to fill from your strain log; the
host organism and construct context are correct, the exact allele strings are not.

```json
{
  "projects": [
    {
      "id": "prj-001",
      "title": "Constrained AID degron (cAID)",
      "description": "mIAA7 embedded within GFP's exposed loop after E172, constraining the degron so it only triggers turnover on auxin. Validated in Y. lipolytica using an RFP nanobody and the carotenoid enzyme CrtW as targets.",
      "status": "manuscript_prep",
      "priority": "high",
      "start_date": null,
      "target_date": null,
      "tags": ["AID2", "GFP", "mIAA7", "Yarrowia"]
    },
    {
      "id": "prj-002",
      "title": "dGFP degron-core mutant screen",
      "description": "Screen of six mIAA7 degron-core variants on p5219 (V2A, P7G, V8A, V8G, R9A, R9K), measuring leaky degradation, fold integrity, and IAA induction efficiency. Readouts: GFP fluorescence spectra and OD-normalized degradation kinetics.",
      "status": "active",
      "priority": "high",
      "start_date": null,
      "target_date": null,
      "tags": ["dGFP", "AID2", "p5219", "kinetics"]
    },
    {
      "id": "prj-003",
      "title": "PFOA biosorption via hLFABP surface display",
      "description": "Engineered Y. lipolytica displaying GFP-hLFABP for PFOA bioremediation. PFOA removal quantified by LC-MS/MS, analysed with ANOVA and Tukey HSD.",
      "status": "active",
      "priority": "medium",
      "start_date": null,
      "target_date": null,
      "tags": ["PFOA", "biosorption", "hLFABP", "Yarrowia"]
    },
    {
      "id": "prj-004",
      "title": "Self-excising polyprotein cassette",
      "description": "Split-intein polyprotein cassette combined with AID2. Includes the split-intein AND-gate concept (Route 2: PTS controls whether the degron connects to the target protein, rather than splitting the degron core) and a dTAG feasibility path for plant deployment.",
      "status": "planning",
      "priority": "medium",
      "start_date": null,
      "target_date": null,
      "tags": ["intein", "AND-gate", "AID2", "dTAG"]
    },
    {
      "id": "prj-005",
      "title": "Cyanobacterial intein genome scan",
      "description": "Scanning cyanobacterial genomes (Nostoc commune, N. flagelliforme, Aphanizomenon flos-aquae, Arthrospira platensis FACHB-835) for inteins. Found DnaE split inteins conserved across all three cyanobacteria scanned, DnaB/DnaX contiguous inteins in both Nostoc species, and a novel NrdJ maxi-intein in N. commune. Structural mini-intein trimming followed.",
      "status": "active",
      "priority": "medium",
      "start_date": null,
      "target_date": null,
      "tags": ["intein", "DnaE", "DnaB", "mini-intein"]
    },
    {
      "id": "prj-006",
      "title": "De novo USP7 binder design",
      "description": "De novo binder design targeting USP7 (PDB 1NBF) using RFdiffusion, ProteinMPNN, and AF2-Multimer, with PyMOL hotspot analysis. Runs on the RTX 5090 workstation.",
      "status": "active",
      "priority": "medium",
      "start_date": null,
      "target_date": null,
      "tags": ["USP7", "RFdiffusion", "ProteinMPNN", "binder"]
    }
  ],

  "manuscripts": [
    {
      "id": "ms-001",
      "project_id": "prj-001",
      "title": "Constrained AID degron for tunable protein depletion in Yarrowia lipolytica",
      "target_journal": "ACS Synthetic Biology",
      "status": "accepted",
      "submission_id": "sb-2025-009706.R1",
      "submitted_date": null,
      "notes": "Accepted after first revision."
    }
  ],

  "strains": [
    {
      "id": "str-2407",
      "name": "2407",
      "host_organism": "Yarrowia lipolytica",
      "genotype": "VERIFY",
      "plasmid": "",
      "construct_notes": "dGFP reference strain",
      "freezer_location": "",
      "notes": ""
    },
    {
      "id": "str-2419",
      "name": "2419",
      "host_organism": "Yarrowia lipolytica",
      "genotype": "VERIFY",
      "plasmid": "p5219",
      "construct_notes": "IAA-inducible AID2 + dGFP variant",
      "freezer_location": "",
      "notes": ""
    },
    {
      "id": "str-2542",
      "name": "2542",
      "host_organism": "Yarrowia lipolytica",
      "genotype": "VERIFY",
      "plasmid": "p5219",
      "construct_notes": "IAA-inducible AID2 + dGFP variant",
      "freezer_location": "",
      "notes": ""
    },
    {
      "id": "str-2904",
      "name": "2904",
      "host_organism": "Yarrowia lipolytica",
      "genotype": "VERIFY",
      "plasmid": "",
      "construct_notes": "dGFP kinetics strain",
      "freezer_location": "",
      "notes": ""
    }
  ],

  "experiments": [
    {
      "id": "exp-001",
      "project_id": "prj-002",
      "title": "GFP fluorescence spectra, dGFP variants",
      "hypothesis": "Degron-core mutations shift baseline GFP folding/brightness in the absence of IAA.",
      "status": "done",
      "date": null,
      "strain_ids": ["str-2419", "str-2542"],
      "protocol_ref": "Plate-reader emission scan",
      "results_notes": "",
      "data_links": []
    },
    {
      "id": "exp-002",
      "project_id": "prj-002",
      "title": "OD-normalized degradation kinetics, strains 2419 and 2542",
      "hypothesis": "IAA induction drives dGFP turnover; rate varies by degron-core variant.",
      "status": "running",
      "date": null,
      "strain_ids": ["str-2419", "str-2542"],
      "protocol_ref": "Time-course GFP signal / OD600",
      "results_notes": "",
      "data_links": []
    },
    {
      "id": "exp-003",
      "project_id": "prj-002",
      "title": "Anti-FLAG Western, liberation QC gate",
      "hypothesis": "Degron liberation from the fusion is intact before kinetics are trusted.",
      "status": "planned",
      "date": null,
      "strain_ids": ["str-2542"],
      "protocol_ref": "SDS-PAGE + anti-FLAG blot",
      "results_notes": "Gate: pass before accepting CHX-chase data.",
      "data_links": []
    },
    {
      "id": "exp-004",
      "project_id": "prj-003",
      "title": "PFOA biosorption pilot, LC-MS/MS",
      "hypothesis": "GFP-hLFABP surface display increases PFOA removal vs control.",
      "status": "done",
      "date": null,
      "strain_ids": [],
      "protocol_ref": "Biosorption assay + LC-MS/MS",
      "results_notes": "Analysed with ANOVA and Tukey HSD.",
      "data_links": []
    },
    {
      "id": "exp-005",
      "project_id": "prj-005",
      "title": "Mini-intein trimming, NFL1 DnaB",
      "hypothesis": "HEN-domain deletion yields a folded 137 aa mini-intein.",
      "status": "done",
      "date": null,
      "strain_ids": [],
      "protocol_ref": "pLDDT-guided Cα analysis on CIF/PDB",
      "results_notes": "Top candidate: NFL1 DnaB, 137 aa, avg pLDDT 94.9.",
      "data_links": []
    },
    {
      "id": "exp-006",
      "project_id": "prj-006",
      "title": "USP7 hotspot selection",
      "hypothesis": "Surface hotspots on 1NBF define a designable binding patch.",
      "status": "running",
      "date": null,
      "strain_ids": [],
      "protocol_ref": "PyMOL hotspot analysis on PDB 1NBF",
      "results_notes": "",
      "data_links": []
    }
  ],

  "reagents": []
}
```

---

## 5. The six staged prompts

Paste one per session, in order. Each assumes the previous stage built and ran.

### Prompt 1 — Scaffold + schema

```
Read SPEC.md. Build the project described there.

This stage only: scaffold a project using the stack declared in SPEC.md,
get it to build and run on one platform, and generate the database schema
and types for every entity in Section 3 (Project, Experiment, Task, Strain,
Reagent, Manuscript), with local SQLite persistence. No UI beyond a blank
running app.

Pin the framework and library versions you choose and list them. Show me
the generated schema. Confirm the app runs before we build any screens.
```

### Prompt 2 — Projects, end to end

```
Read SPEC.md. The schema from Stage 1 is in place and the app runs.

Build the Project entity end to end against that schema: list view, create,
edit, delete, all persisting to local SQLite. Use the Project fields and the
ProjectStatus / Priority enums from Section 3 exactly.

Then load the six projects and the one manuscript from Section 4 as seed data
on first run. Convert the JSON to the stack's insert format and keep the
foreign-key reference from the manuscript to prj-001 intact.

Show me the running list of six projects. Confirm create/edit/delete persist
across a restart before we move on.
```

### Prompt 3 — Experiments + Tasks

```
Read SPEC.md. Projects work and persist.

Add the Experiment and Task entities from Section 3, each with list, create,
edit, delete. Experiments belong to a Project (project_id) and reference
Strains via strain_ids. Tasks can attach to a Project, an Experiment, or
neither. Use the enums (ExperimentStatus, TaskStatus, Priority) exactly.

From a Project's detail view I want to see its Experiments and Tasks. From an
Experiment I want to see its linked Tasks.

Load the experiments from Section 4 seed data, wired to the right projects.
Strain references will resolve once Stage 4 loads the strains; handle missing
strain IDs gracefully until then. Confirm it runs.
```

### Prompt 4 — Strain + Reagent inventory

```
Read SPEC.md. Projects, Experiments, and Tasks work.

Add the Strain and Reagent inventory from Section 3: searchable list views,
create, edit, delete for each. Use the fields exactly.

Load the four strains from Section 4 seed data. Now resolve the strain_ids on
the seeded Experiments so an Experiment's detail view shows its strains by name,
and a Strain's detail view shows which Experiments used it.

For Reagents, add an expiry indicator: flag any reagent whose expiry_date is
within 30 days. Confirm it runs.
```

### Prompt 5 — Supabase backend + sync

```
Read SPEC.md. The full local app works against SQLite.

Add a Supabase backend and two-way sync for all six tables, keeping local
SQLite as the offline source of truth (local-first: the app must work with no
network, then sync when it reconnects). Add email/password auth so my data is
tied to my account.

Generate the Supabase table definitions matching Section 3, including foreign
keys and row-level security so a user only sees their own rows. Tell me exactly
which env vars and Supabase project settings I need to set, and what to paste
where. Do not hard-code any keys.

Walk me through testing it: create a project on one device, confirm it appears
on another after sync.
```

### Prompt 6 — Views + polish

```
Read SPEC.md. The app syncs across devices.

Add these views, against the existing data:

1. A board grouping Projects by status (planning / active / manuscript_prep /
   under_review / published / shelved), drag to change status.
2. Filters on the Project list: by status, priority, and tag.
3. A deadline view: every Task and Experiment with a due_date/date, sorted,
   with overdue items flagged. Wire up local notifications for tasks due today.
4. A dashboard: count of projects by status, count of experiments by status,
   reagents expiring within 30 days, and the next five upcoming deadlines.

Keep it usable on a phone screen, not just desktop. Confirm it runs on at
least one mobile target.
```

---

## 6. Session rules

A few practices keep the agent on track across a multi-stage build.

Name the stack and versions once here and refer back to them, so the agent stops
re-deciding mid-build. Scope each session to a single stage; a prompt that asks
for three features gets you three half-built features. Make the agent run the app
and show you it works at the end of every stage, because "it should work" and "it
runs" are different claims. And keep this file current: when you change the schema
or add a project, edit the relevant section, because the next session's first
instruction is to read it.

When something breaks, paste the actual error and the file it came from rather than
describing it. Agents debug from stack traces far better than from paraphrase.
