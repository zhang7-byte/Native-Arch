// Status enumerations for the LabTrack data model (SPEC.md Section 3).
//
// drift's `textEnum<T>()` persists `Enum.name`, so each constant below is named
// in the exact form used by SPEC.md. That keeps the values stored in SQLite
// identical to the spec (e.g. 'manuscript_prep') and maps cleanly onto Postgres
// enum/text values when Supabase sync is added at Stage 5.
//
// ignore_for_file: constant_identifier_names

/// Lifecycle of a research project.
enum ProjectStatus {
  planning,
  active,
  manuscript_prep,
  under_review,
  published,
  shelved,
}

/// Shared priority scale, used by Project and Task.
enum Priority { low, medium, high }

/// Lifecycle of an experiment.
enum ExperimentStatus { planned, running, done, failed }

/// Lifecycle of a task.
enum TaskStatus { todo, doing, done, blocked }

/// Lifecycle of a manuscript.
enum ManuscriptStatus { drafting, submitted, revision, accepted, published }
