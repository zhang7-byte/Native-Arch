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

    static func color(for p: Priority) -> Color {
        switch p {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

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
