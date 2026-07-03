import Foundation

// MARK: - Enums (values match the Flutter/drift schema exactly)

enum ProjectStatus: String, CaseIterable, Identifiable, Codable {
    case planning, active, manuscript_prep, under_review, published, shelved
    var id: String { rawValue }
    var label: String {
        switch self {
        case .planning: return "Planning"
        case .active: return "Active"
        case .manuscript_prep: return "Manuscript prep"
        case .under_review: return "Under review"
        case .published: return "Published"
        case .shelved: return "Shelved"
        }
    }
}

enum Priority: String, CaseIterable, Identifiable, Codable {
    case low, medium, high
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum ExperimentStatus: String, CaseIterable, Identifiable, Codable {
    case planned, running, done, failed
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

// MARK: - Entities (subset for Phase 1; more added with their sections)

struct Project: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String = ""
    var description: String = ""
    var status: ProjectStatus = .planning
    var priority: Priority = .medium
    var startDate: Date?
    var targetDate: Date?
    var tags: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct Experiment: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var projectId: String = ""
    var title: String = ""
    var hypothesis: String = ""
    var status: ExperimentStatus = .planned
    var date: Date?
    var strainIds: [String] = []
    var protocolRef: String = ""
    var methodologySteps: [String] = []
    var resultsNotes: String = ""
    var conclusion: String = ""
    var furtherPlan: String = ""
    var dataLinks: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}
