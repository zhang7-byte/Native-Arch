import SwiftUI

/// The app's sections, mirroring the Flutter navigation rail. Projects and
/// Experiments are implemented; the rest are placeholders for now.
enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard, projects, board, deadlines, schedule, experiments, tasks,
         strains, reagents, cultures, primers, cloning, protocols, report,
         workspace, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .projects: return "Projects"
        case .board: return "Board"
        case .deadlines: return "Deadlines"
        case .schedule: return "Schedule"
        case .experiments: return "Experiments"
        case .tasks: return "Tasks"
        case .strains: return "Strains"
        case .reagents: return "Reagents"
        case .cultures: return "Cultures"
        case .primers: return "Primers"
        case .cloning: return "Cloning"
        case .protocols: return "Protocols"
        case .report: return "Report"
        case .workspace: return "Workspace"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .projects: return "flask"
        case .board: return "rectangle.split.3x1"
        case .deadlines: return "calendar.badge.exclamationmark"
        case .schedule: return "calendar"
        case .experiments: return "testtube.2"
        case .tasks: return "checklist"
        case .strains: return "allergens"
        case .reagents: return "shippingbox"
        case .cultures: return "drop"
        case .primers: return "waveform.path"
        case .cloning: return "circle.hexagongrid"
        case .protocols: return "book"
        case .report: return "doc.text"
        case .workspace: return "person.2"
        case .settings: return "gearshape"
        }
    }

    var implemented: Bool { self == .projects || self == .experiments }
}

/// Liquid Glass navigation shell: a sidebar of sections with a detail pane.
struct RootView: View {
    @State private var selection: AppSection? = .projects

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("LabTrack")
        } detail: {
            switch selection ?? .projects {
            case .projects: ProjectsView()
            case .experiments: ExperimentsView()
            default: ComingSoonView(section: selection ?? .dashboard)
            }
        }
    }
}

/// Placeholder for sections not yet ported.
struct ComingSoonView: View {
    let section: AppSection

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: section.icon)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(section.title)
                .font(.title2.weight(.semibold))
            Text("Coming soon in the native reforge.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(section.title)
    }
}
