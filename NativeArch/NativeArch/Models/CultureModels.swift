import Foundation

enum CultureStatus: String, CaseIterable, Identifiable, Codable {
    case active, terminated, archived
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum CultureEventType: String, CaseIterable, Identifiable, Codable {
    case sampling, reagent, induction, split, measurement, note
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

struct Culture: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var strainId: String?
    var status: CultureStatus = .active
    var medium: String = ""
    var vessel: String = ""
    var startedDate: Date = Date()
    var endedDate: Date?
    var notes: String = ""
    var purpose: String = ""
    var inoculumAmount: String = ""
    var selectionMarkers: [String] = []
    var parentCultureId: String?
    var parentInoculatedAt: Date?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct CultureEvent: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var cultureId: String = ""
    var happenedAt: Date = Date()
    var type: CultureEventType = .note
    var agent: String = ""
    var amount: String = ""
    var note: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}
