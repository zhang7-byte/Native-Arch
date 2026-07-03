import SwiftUI

struct ReportsView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Report?
    @State private var creating = false

    var body: some View {
        List {
            ForEach(store.reports) { report in
                Button { editing = report } label: { ReportRow(report: report) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteReport(report.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Report")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New report", systemImage: "plus") }
            }
        }
        .overlay {
            if store.reports.isEmpty {
                ContentUnavailableView("No reports yet", systemImage: "doc.text",
                    description: Text("Tap + to add one."))
            }
        }
        .sheet(item: $editing) { ReportEditor(report: $0) }
        .sheet(isPresented: $creating) { ReportEditor(report: nil) }
    }
}

struct ReportRow: View {
    let report: Report

    private var period: String {
        let f: (Date) -> String = { $0.formatted(date: .abbreviated, time: .omitted) }
        switch (report.periodStart, report.periodEnd) {
        case let (s?, e?): return "\(f(s)) – \(f(e))"
        case let (s?, nil): return "from \(f(s))"
        case let (nil, e?): return "to \(f(e))"
        default: return ""
        }
    }

    private var meta: String {
        [report.recipient.isEmpty ? nil : "to \(report.recipient)",
         period.isEmpty ? nil : period].compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(report.title).font(.headline)
            if !meta.isEmpty {
                Text(meta).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
