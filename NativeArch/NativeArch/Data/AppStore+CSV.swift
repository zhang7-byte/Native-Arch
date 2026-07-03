import Foundation

extension AppStore {
    private static let iso = ISO8601DateFormatter()

    // MARK: - Strains

    func strainsCSV() -> String {
        var rows: [[String]] = [["name", "serialNumber", "hostOrganism", "genotype",
                                 "plasmid", "constructNotes", "selectionMarkers",
                                 "freezerLocation", "notes"]]
        for s in strains {
            rows.append([s.name, s.serialNumber, s.hostOrganism, s.genotype, s.plasmid,
                         s.constructNotes, s.selectionMarkers.joined(separator: "|"),
                         s.freezerLocation, s.notes])
        }
        return CSV.encode(rows)
    }

    func importStrainsCSV(_ text: String) {
        let rows = CSV.parse(text)
        guard rows.count > 1 else { return }
        for r in rows.dropFirst() where r.count >= 1 && !r[0].isEmpty {
            func f(_ i: Int) -> String { i < r.count ? r[i] : "" }
            saveStrain(Strain(
                name: f(0), serialNumber: f(1), hostOrganism: f(2), genotype: f(3),
                plasmid: f(4), constructNotes: f(5),
                selectionMarkers: f(6).split(separator: "|").map(String.init),
                freezerLocation: f(7), notes: f(8)))
        }
    }

    // MARK: - Reagents

    func reagentsCSV() -> String {
        var rows: [[String]] = [["name", "kind", "supplier", "catalogNo", "lot",
                                 "location", "expiryDate", "quantity", "recipe", "notes"]]
        for r in reagents {
            rows.append([r.name, r.kind, r.supplier, r.catalogNo, r.lot, r.location,
                         r.expiryDate.map { Self.iso.string(from: $0) } ?? "",
                         r.quantity, r.recipe, r.notes])
        }
        return CSV.encode(rows)
    }

    func importReagentsCSV(_ text: String) {
        let rows = CSV.parse(text)
        guard rows.count > 1 else { return }
        for r in rows.dropFirst() where r.count >= 1 && !r[0].isEmpty {
            func f(_ i: Int) -> String { i < r.count ? r[i] : "" }
            saveReagent(Reagent(
                name: f(0), kind: f(1).isEmpty ? "reagent" : f(1), supplier: f(2),
                catalogNo: f(3), lot: f(4), location: f(5),
                expiryDate: Self.iso.date(from: f(6)), quantity: f(7), recipe: f(8), notes: f(9)))
        }
    }

    // MARK: - Primers

    func primersCSV() -> String {
        var rows: [[String]] = [["name", "serialNumber", "sequence", "targetGene",
                                 "direction", "tm", "supplier", "notes"]]
        for p in primers {
            rows.append([p.name, p.serialNumber, p.sequence, p.targetGene,
                         p.direction, p.tm, p.supplier, p.notes])
        }
        return CSV.encode(rows)
    }

    func importPrimersCSV(_ text: String) {
        let rows = CSV.parse(text)
        guard rows.count > 1 else { return }
        for r in rows.dropFirst() where r.count >= 1 && !r[0].isEmpty {
            func f(_ i: Int) -> String { i < r.count ? r[i] : "" }
            savePrimer(Primer(
                name: f(0), serialNumber: f(1), sequence: f(2), targetGene: f(3),
                direction: f(4), tm: f(5), supplier: f(6), notes: f(7)))
        }
    }
}
