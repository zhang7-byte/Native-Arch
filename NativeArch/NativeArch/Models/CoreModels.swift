import Foundation

enum TaskStatus: String, CaseIterable, Identifiable, Codable {
    case todo, doing, done, blocked
    var id: String { rawValue }
    var label: String {
        switch self {
        case .todo: return "To do"
        case .doing: return "Doing"
        case .done: return "Done"
        case .blocked: return "Blocked"
        }
    }
}

struct Task: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var projectId: String?
    var experimentId: String?
    var title: String = ""
    var description: String = ""
    var dueDate: Date?
    var status: TaskStatus = .todo
    var priority: Priority = .medium
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct Strain: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var serialNumber: String = ""
    var hostOrganism: String = ""
    var genotype: String = ""
    var plasmid: String = ""
    var constructNotes: String = ""
    var selectionMarkers: [String] = []
    var freezerLocation: String = ""
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct Reagent: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var kind: String = "reagent" // "reagent" | "buffer"
    var supplier: String = ""
    var catalogNo: String = ""
    var lot: String = ""
    var location: String = ""
    var expiryDate: Date?
    var quantity: String = ""
    var recipe: String = ""
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var isBuffer: Bool { kind == "buffer" }
}
