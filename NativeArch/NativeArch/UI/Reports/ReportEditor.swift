import SwiftUI
import UniformTypeIdentifiers

struct ReportEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Report
    @State private var hasStart: Bool
    @State private var hasEnd: Bool
    @State private var pdfDoc = PDFFileDocument()
    @State private var showPDF = false
    private let isNew: Bool

    init(report: Report?) {
        _draft = State(initialValue: report ?? Report())
        _hasStart = State(initialValue: report?.periodStart != nil)
        _hasEnd = State(initialValue: report?.periodEnd != nil)
        isNew = report == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $draft.title)
                    TextField("Recipient (PI)", text: $draft.recipient)
                    TextField("Author", text: $draft.author)
                }
                Section("Reporting period") {
                    Toggle("Start", isOn: $hasStart)
                    if hasStart {
                        DatePicker("Start", selection: Binding(
                            get: { draft.periodStart ?? Date() },
                            set: { draft.periodStart = $0 }), displayedComponents: .date)
                    }
                    Toggle("End", isOn: $hasEnd)
                    if hasEnd {
                        DatePicker("End", selection: Binding(
                            get: { draft.periodEnd ?? Date() },
                            set: { draft.periodEnd = $0 }), displayedComponents: .date)
                    }
                }
                Section("Summary") {
                    TextField("Written summary", text: $draft.summary, axis: .vertical)
                        .lineLimit(4...12)
                }
            }
            .navigationTitle(isNew ? "New report" : "Edit report")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem {
                    Button {
                        pdfDoc = PDFFileDocument(data: renderPDF(ReportPDFView(report: draft)))
                        showPDF = true
                    } label: { Label("Export PDF", systemImage: "arrow.down.doc") }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .fileExporter(isPresented: $showPDF, document: pdfDoc, contentType: .pdf,
                          defaultFilename: draft.title) { _ in }
        }
    }

    private func save() {
        if !hasStart { draft.periodStart = nil }
        if !hasEnd { draft.periodEnd = nil }
        draft.title = draft.title.trimmingCharacters(in: .whitespaces)
        store.saveReport(draft)
        dismiss()
    }
}

/// The printable layout for a report PDF.
struct ReportPDFView: View {
    let report: Report

    private var period: String {
        let f: (Date) -> String = { $0.formatted(date: .abbreviated, time: .omitted) }
        switch (report.periodStart, report.periodEnd) {
        case let (s?, e?): return "\(f(s)) – \(f(e))"
        case let (s?, nil): return "from \(f(s))"
        case let (nil, e?): return "to \(f(e))"
        default: return "—"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(report.title).font(.system(size: 24, weight: .bold))
            Group {
                if !report.recipient.isEmpty { Text("To: \(report.recipient)") }
                if !report.author.isEmpty { Text("From: \(report.author)") }
                Text("Period: \(period)")
            }
            .font(.system(size: 12)).foregroundStyle(.secondary)
            Divider()
            Text(report.summary.isEmpty ? "(no summary)" : report.summary)
                .font(.system(size: 12))
            Spacer(minLength: 0)
        }
        .padding(36)
        .foregroundStyle(.black)
    }
}
