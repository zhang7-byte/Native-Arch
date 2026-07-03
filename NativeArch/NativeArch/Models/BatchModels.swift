import Foundation

struct Primer: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var serialNumber: String = ""
    var sequence: String = ""
    var targetGene: String = ""
    var direction: String = ""
    var tm: String = ""
    var supplier: String = ""
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    /// Derived for display (not stored), matching the Flutter app.
    var length: Int {
        sequence.filter { !$0.isWhitespace }.count
    }
}

struct LabProtocol: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var category: String = ""
    var summary: String = ""
    var steps: [String] = []
    var stepIds: [String] = []
    var materials: String = ""
    var notes: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct Report: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String = "Progress report"
    var recipient: String = ""
    var author: String = ""
    var periodStart: Date?
    var periodEnd: Date?
    var summary: String = ""
    var projectIds: [String] = []
    var experimentIds: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

/// One PCR fragment in a Gibson assembly. Codable keys match the Flutter JSON
/// exactly for interop.
struct CloneFragment: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String = ""
    var templateStrainId: String = ""
    var fwdPrimerId: String = ""
    var revPrimerId: String = ""
    var sizeBp: String = ""
    var notes: String = ""

    enum CodingKeys: String, CodingKey {
        case name, templateStrainId, fwdPrimerId, revPrimerId, sizeBp, notes
    }
}

struct CloneConstruction: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var notes: String = ""
    var backboneName: String = ""
    var backboneStrainId: String = ""
    var enzymes: String = ""
    var fragments: [CloneFragment] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

// MARK: - Fragment JSON helpers

func encodeFragments(_ list: [CloneFragment]) -> String {
    guard let data = try? JSONEncoder().encode(list),
          let s = String(data: data, encoding: .utf8) else { return "[]" }
    return s
}

func decodeFragments(_ raw: String) -> [CloneFragment] {
    guard let data = raw.data(using: .utf8),
          let list = try? JSONDecoder().decode([CloneFragment].self, from: data) else { return [] }
    return list
}
