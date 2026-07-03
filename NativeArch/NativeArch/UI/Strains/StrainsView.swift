import SwiftUI
import UniformTypeIdentifiers

struct StrainsView: View {
    @Environment(AppStore.self) private var store
    @State private var editing: Strain?
    @State private var creating = false
    @State private var csvDoc = CSVDocument()
    @State private var showExport = false
    @State private var showImport = false

    var body: some View {
        List {
            ForEach(store.strains) { strain in
                Button { editing = strain } label: { StrainRow(strain: strain) }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { store.deleteStrain(strain.id) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Strains")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New strain", systemImage: "plus") }
            }
            ToolbarItem {
                Menu {
                    Button { csvDoc = CSVDocument(text: store.strainsCSV()); showExport = true } label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    }
                    Button { showImport = true } label: {
                        Label("Import CSV", systemImage: "square.and.arrow.down")
                    }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .overlay {
            if store.strains.isEmpty {
                ContentUnavailableView("No strains yet", systemImage: "allergens",
                    description: Text("Tap + to add one."))
            }
        }
        .sheet(item: $editing) { StrainEditor(strain: $0) }
        .sheet(isPresented: $creating) { StrainEditor(strain: nil) }
        .fileExporter(isPresented: $showExport, document: csvDoc,
                      contentType: .commaSeparatedText, defaultFilename: "strains") { _ in }
        .fileImporter(isPresented: $showImport,
                      allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
            if case .success(let url) = result { store.importStrainsCSV(readCSV(url)) }
        }
    }
}

/// Reads a security-scoped picked file as UTF-8 text.
func readCSV(_ url: URL) -> String {
    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
    return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
}

struct StrainRow: View {
    let strain: Strain

    private var subtitle: String {
        [strain.serialNumber.isEmpty ? nil : "#\(strain.serialNumber)",
         strain.hostOrganism.isEmpty ? nil : strain.hostOrganism,
         strain.plasmid.isEmpty ? nil : "plasmid \(strain.plasmid)"]
            .compactMap { $0 }.joined(separator: " · ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(strain.name).font(.headline)
            if !subtitle.isEmpty {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            }
            if !strain.selectionMarkers.isEmpty {
                HStack(spacing: 6) {
                    StatusChip(text: strain.selectionMarkers.joined(separator: ", "),
                               color: .teal)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
