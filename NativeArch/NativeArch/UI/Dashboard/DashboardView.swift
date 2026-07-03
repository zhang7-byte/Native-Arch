import SwiftUI

struct DashboardView: View {
    @Environment(AppStore.self) private var store

    private var startOfToday: Date { Calendar.current.startOfDay(for: Date()) }
    private var endOfToday: Date { Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)! }

    private var overdue: [Task] {
        store.tasks.filter { $0.status != .done && ($0.dueDate.map { $0 < startOfToday } ?? false) }
    }
    private var openTasks: Int { store.tasks.filter { $0.status != .done }.count }
    private var runningExp: Int { store.experiments.filter { $0.status == .running }.count }
    private var activeCultures: Int { store.cultures.filter { $0.status == .active }.count }
    private var expiringReagents: Int {
        let soon = Calendar.current.date(byAdding: .day, value: 30, to: startOfToday)!
        return store.reagents.filter { $0.expiryDate.map { $0 <= soon } ?? false }.count
    }
    private var dueToday: [Task] {
        store.tasks.filter { t in t.dueDate.map { $0 >= startOfToday && $0 < endOfToday } ?? false }
    }
    private var upcoming: [(date: Date, label: String, kind: String)] {
        var items: [(Date, String, String)] = []
        for t in store.tasks where t.status != .done {
            if let d = t.dueDate, d >= startOfToday { items.append((d, t.title, "Task")) }
        }
        for p in store.projects {
            if let d = p.targetDate, d >= startOfToday { items.append((d, p.title, "Project")) }
        }
        return items.sorted { $0.0 < $1.0 }.prefix(8).map { ($0.0, $0.1, $0.2) }
    }

    private let cols = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(.title3.weight(.semibold))

                LazyVGrid(columns: cols, spacing: 14) {
                    KpiCard(value: "\(store.projects.count)", label: "Projects",
                            icon: "flask", tint: .blue)
                    KpiCard(value: "\(runningExp)", label: "Running exp.",
                            icon: "testtube.2", tint: .teal)
                    KpiCard(value: "\(openTasks)", label: "Open tasks",
                            icon: "checklist", tint: .indigo)
                    KpiCard(value: "\(overdue.count)", label: "Overdue",
                            icon: "exclamationmark.triangle", tint: overdue.isEmpty ? .green : .red)
                    KpiCard(value: "\(activeCultures)", label: "Active cultures",
                            icon: "drop", tint: .purple)
                    KpiCard(value: "\(expiringReagents)", label: "Expiring reagents",
                            icon: "shippingbox", tint: expiringReagents == 0 ? .green : .orange)
                }

                if !dueToday.isEmpty {
                    SectionHeader("Due today")
                    ForEach(dueToday) { t in
                        RowLine(dot: Palette.color(for: t.status), title: t.title, subtitle: t.status.label)
                    }
                }

                SectionHeader("Upcoming deadlines (\(upcoming.count))")
                if upcoming.isEmpty {
                    Text("Nothing upcoming.").foregroundStyle(.secondary)
                } else {
                    ForEach(upcoming, id: \.date) { item in
                        RowLine(dot: item.kind == "Task" ? .indigo : .blue,
                                title: item.label,
                                subtitle: "\(item.kind) · \(item.date.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Dashboard")
    }
}

private struct KpiCard: View {
    let value: String, label: String, icon: String
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(tint)
            Text(value).font(.system(size: 30, weight: .bold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular.tint(tint.opacity(0.12)), in: .rect(cornerRadius: 18))
    }
}

private struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.headline).padding(.top, 4)
    }
}

private struct RowLine: View {
    let dot: Color, title: String, subtitle: String
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(dot).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.medium)).lineLimit(1)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
