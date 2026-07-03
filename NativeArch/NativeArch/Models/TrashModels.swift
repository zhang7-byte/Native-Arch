import Foundation

struct TrashEntry: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var entityTable: String = ""
    var entityId: String = ""
    var kind: String = ""
    var label: String = ""
    var deletedAt: Date = Date()
    var payload: String = ""
}
