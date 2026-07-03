import SwiftUI

/// Section palette + small Liquid Glass helpers shared across the app.
enum Palette {
    static func color(for s: ProjectStatus) -> Color {
        switch s {
        case .planning: return .gray
        case .active: return .blue
        case .manuscript_prep: return .purple
        case .under_review: return .orange
        case .published: return .green
        case .shelved: return .brown
        }
    }

    static func color(for s: ExperimentStatus) -> Color {
        switch s {
        case .planned: return .gray
        case .running: return .blue
        case .done: return .green
        case .failed: return .red
        }
    }

    static func color(for s: TaskStatus) -> Color {
        switch s {
        case .todo: return .gray
        case .doing: return .blue
        case .done: return .green
        case .blocked: return .red
        }
    }

    static func color(for s: CultureStatus) -> Color {
        switch s {
        case .active: return .green
        case .terminated: return .red
        case .archived: return .brown
        }
    }

    static func color(for p: Priority) -> Color {
        switch p {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

extension Color {
    /// Build a color from a packed ARGB integer (matches the stored accent).
    init(argb: Int) {
        self = Color(.sRGB,
                     red: Double((argb >> 16) & 0xFF) / 255,
                     green: Double((argb >> 8) & 0xFF) / 255,
                     blue: Double(argb & 0xFF) / 255,
                     opacity: Double((argb >> 24) & 0xFF) / 255)
    }
}

func colorScheme(for mode: String) -> ColorScheme? {
    switch mode {
    case "light": return .light
    case "dark": return .dark
    default: return nil
    }
}

/// Preset accent colors offered in Settings (label, ARGB).
let accentPresets: [(name: String, argb: Int)] = [
    ("Teal", 0xFF009688),
    ("Terracotta", 0xFFC96442),
    ("Blue", 0xFF2E6FF2),
    ("Purple", 0xFF7C4DFF),
    ("Green", 0xFF2E9E5B),
    ("Orange", 0xFFF08A24),
    ("Pink", 0xFFE0559C),
    ("Indigo", 0xFF3F51B5),
]

/// A small pill label rendered on Liquid Glass, tinted to the given color.
struct StatusChip: View {
    let text: String
    var color: Color = .accentColor

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .glassEffect(.regular.tint(color.opacity(0.18)), in: .capsule)
    }
}
