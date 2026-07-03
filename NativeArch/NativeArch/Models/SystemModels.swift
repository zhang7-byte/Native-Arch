import Foundation

enum EventCategory: String, CaseIterable, Identifiable, Codable {
    case personal, birthday, meeting, reminder, other
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .personal: return "person"
        case .birthday: return "gift"
        case .meeting: return "person.2"
        case .reminder: return "bell"
        case .other: return "calendar"
        }
    }
}

struct CustomEvent: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String = ""
    var date: Date = Date()
    var category: EventCategory = .personal
    var note: String = ""
    var repeatAnnually: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

struct AppSettings {
    var themeMode: String = "system"   // system | light | dark
    var accentColor: Int = 0xFF009688  // ARGB
    var density: String = "comfortable"
    var notifyFrequency: String = "daily"
    var holidayRegion: String = "none"
    var scheduleNotify: Bool = true
}

struct Workspace: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String = "My Lab"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}
